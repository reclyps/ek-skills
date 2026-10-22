#!/usr/bin/env python3
"""Deterministic pre-flight checks: permission rules + CLI presence/auth.

This script handles the parts a pre-flight check can verify WITHOUT model
judgement: whether planned bash commands would be allowed/denied/prompted by
the settings files and Bash PreToolUse hooks in the given permission mode, and
whether required CLIs exist and are authenticated.

Bash PreToolUse hooks from the settings files are run with a synthetic payload,
so they must be side-effect free. Plugin hooks are not checked.

MCP connectivity is NOT checked here — only Claude can call MCP tools — so any
servers passed via --mcp are echoed back as a reminder for Claude to probe.

Exit code: 0 = all green. 1 = at least one RED (denied / missing / auth-failed)
or AMBER (would prompt). Fail-fast callers should halt on a non-zero exit.

Usage:
  preflight.py --commands "git commit" "npm run build" --clis gh jq \
               --mcp Figma Atlassian --cwd /path/to/project --mode auto
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# CLIs whose authentication we can probe cheaply. Maps cli -> probe argv.
# A zero exit means authenticated; non-zero means present-but-not-authed.
AUTH_PROBES = {
    "gh": ["gh", "auth", "status"],
    "gcloud": ["gcloud", "auth", "list", "--filter=status:ACTIVE", "--format=value(account)"],
    "aws": ["aws", "sts", "get-caller-identity"],
    "az": ["az", "account", "show"],
    "docker": ["docker", "info"],
    "kubectl": ["kubectl", "version", "--client"],
}

RED, AMBER, GREEN = "RED", "AMBER", "GREEN"


def discover_settings(cwd: Path):
    """Return existing settings files in precedence order (highest first).

    Deny rules win globally regardless of file, so precedence only matters for
    reporting which file a rule came from.
    """
    candidates = [
        cwd / ".claude" / "settings.local.json",
        cwd / ".claude" / "settings.json",
        Path.home() / ".claude" / "settings.local.json",
        Path.home() / ".claude" / "settings.json",
    ]
    return [p for p in candidates if p.is_file()]


def load_permissions(files):
    """Merge allow/deny/ask arrays across settings files. Returns dict with
    each rule tagged by its source file, plus the effective defaultMode."""
    merged = {"allow": [], "deny": [], "ask": []}
    default_mode = "default"
    for f in files:
        try:
            data = json.loads(f.read_text())
        except (json.JSONDecodeError, OSError) as e:
            print(f"WARN: could not read {f}: {e}", file=sys.stderr)
            continue
        perms = data.get("permissions", {})
        if "defaultMode" in perms and default_mode == "default":
            default_mode = perms["defaultMode"]  # highest-precedence file wins
        for bucket in ("allow", "deny", "ask"):
            for rule in perms.get(bucket, []):
                merged[bucket].append((rule, f.name))
    return merged, default_mode


def load_classify_all_shell() -> bool:
    """autoMode.classifyAllShell, which Claude Code reads only from user settings
    (or managed / --settings), never from project files."""
    try:
        data = json.loads((Path.home() / ".claude" / "settings.json").read_text())
    except (json.JSONDecodeError, OSError):
        return False
    return bool(data.get("autoMode", {}).get("classifyAllShell"))


def load_bash_hooks(files):
    """Return (hook_command, source_file) for every PreToolUse hook whose
    matcher covers the Bash tool."""
    hooks = []
    for f in files:
        try:
            data = json.loads(f.read_text())
        except (json.JSONDecodeError, OSError):
            continue
        for entry in data.get("hooks", {}).get("PreToolUse", []):
            matcher = entry.get("matcher", "")
            if matcher not in ("", "*") and not re.fullmatch(matcher, "Bash"):
                continue
            for hook in entry.get("hooks", []):
                if hook.get("type") == "command":
                    hooks.append((hook["command"], f.name))
    return hooks


def hook_decision(command: str, hooks):
    """Run each Bash hook on a synthetic payload. Returns (decision, reason)
    for the first hook that denies or asks, else None."""
    payload = json.dumps({"hook_event_name": "PreToolUse", "tool_name": "Bash",
                          "tool_input": {"command": command}})
    for hook_cmd, src in hooks:
        try:
            proc = subprocess.run(hook_cmd, shell=True, input=payload,
                                  capture_output=True, text=True, timeout=15)
        except subprocess.TimeoutExpired:
            continue
        if proc.returncode == 2:
            return ("deny", f"hook `{hook_cmd}` ({src}) blocks it")
        try:
            out = json.loads(proc.stdout or "{}").get("hookSpecificOutput", {})
        except json.JSONDecodeError:
            continue
        decision = out.get("permissionDecision")
        if decision in ("deny", "ask"):
            reason = out.get("permissionDecisionReason", "")
            return (decision, f"hook `{hook_cmd}` ({src}): {reason}")
    return None


def parse_bash_rule(rule: str):
    """Extract the matchable spec from a permission rule.

    Returns (kind, spec) where kind is:
      'all'    -> bare `Bash`, matches any command
      'prefix' -> `Bash(foo:*)` or `Bash(foo *)`, command must start with `foo`
      'glob'   -> `Bash(az * delete*)`, each `*` stands for any text
      'exact'  -> `Bash(foo)`, command must equal `foo`
      None     -> not a Bash rule (e.g. Read/WebFetch), ignored here
    """
    if rule == "Bash":
        return ("all", None)
    if not (rule.startswith("Bash(") and rule.endswith(")")):
        return (None, None)
    inner = rule[len("Bash("):-1].strip()
    if inner.endswith(":*"):
        return ("prefix", inner[:-2].strip())
    if inner.endswith(" *") and "*" not in inner[:-2]:
        return ("prefix", inner[:-2].strip())
    if "*" in inner:
        return ("glob", inner)
    return ("exact", inner)


def cmd_matches(command: str, rule: str) -> bool:
    """Heuristic match of a planned command against one Bash permission rule.

    Boundary after a prefix may be a space, ':' or end-of-string. This errs
    toward NOT matching ambiguous cases, so the verdict leans conservative
    (reports a prompt rather than silently assuming an allow)."""
    kind, spec = parse_bash_rule(rule)
    cmd = " ".join(command.split())  # normalise whitespace
    if kind == "all":
        return True
    if kind == "exact":
        return cmd == spec
    if kind == "prefix":
        if cmd == spec:
            return True
        if cmd.startswith(spec):
            nxt = cmd[len(spec):len(spec) + 1]
            return nxt in (" ", ":")
        return False
    if kind == "glob":
        pattern = ".*".join(re.escape(part) for part in spec.split("*"))
        return re.fullmatch(pattern, cmd, flags=re.S) is not None
    return False


def classify_command(command: str, perms, mode: str, classify_all_shell: bool, hook):
    """Return (status, reason) in Claude Code's order: deny rules, then hook and
    ask rules (which prompt in every mode, auto included), then the mode decides."""
    for rule, src in perms["deny"]:
        if cmd_matches(command, rule):
            return (RED, f"matched DENY `{rule}` ({src})")
    if hook and hook[0] == "deny":
        return (RED, hook[1])
    if hook:
        return (AMBER, f"{hook[1]} — will prompt; a background agent gets a denial")
    for rule, src in perms["ask"]:
        if cmd_matches(command, rule):
            return (AMBER, f"matched ASK `{rule}` ({src}) — will prompt, even in auto mode")
    if mode == "bypassPermissions":
        return (GREEN, "mode=bypassPermissions")
    allow = next(((r, s) for r, s in perms["allow"] if cmd_matches(command, r)), None)
    if mode == "auto":
        if classify_all_shell:
            return (GREEN, "auto mode: classifier reviews it, no prompt (allow rules suspended by classifyAllShell)")
        if allow:
            return (GREEN, f"matched ALLOW `{allow[0]}` ({allow[1]}), skips the classifier")
        return (GREEN, "auto mode: classifier reviews it, no prompt")
    if allow:
        return (GREEN, f"matched ALLOW `{allow[0]}` ({allow[1]})")
    if mode == "dontAsk":
        return (RED, "no matching allow rule — dontAsk mode auto-denies it")
    if mode == "acceptEdits":
        # acceptEdits auto-accepts edits but still prompts for other tools incl. Bash
        return (AMBER, "no matching rule (acceptEdits still prompts for Bash)")
    return (AMBER, "no matching allow rule — will prompt")


def check_cli(cli: str):
    """Return (status, reason) for a CLI's presence and (if known) auth."""
    if shutil.which(cli) is None:
        return (RED, "not found on PATH")
    if cli not in AUTH_PROBES:
        return (GREEN, "present (no auth probe)")
    try:
        proc = subprocess.run(
            AUTH_PROBES[cli], capture_output=True, text=True, timeout=15
        )
    except subprocess.TimeoutExpired:
        return (AMBER, "auth probe timed out")
    except OSError as e:
        return (AMBER, f"auth probe failed to run: {e}")
    if proc.returncode == 0:
        return (GREEN, "present + authenticated")
    detail = (proc.stderr or proc.stdout or "").strip().splitlines()
    tail = detail[-1] if detail else f"exit {proc.returncode}"
    return (RED, f"present but auth failed: {tail}")


def extract_clis_from_commands(commands):
    """First token of each command is a candidate CLI to verify."""
    out = []
    for c in commands:
        toks = c.split()
        if toks:
            out.append(toks[0])
    return out


ICON = {RED: "RED ", AMBER: "AMBER", GREEN: "GREEN"}


def main():
    ap = argparse.ArgumentParser(description="Pre-flight permission + CLI checks")
    ap.add_argument("--commands", nargs="*", default=[],
                    help="planned bash command strings, e.g. 'git commit'")
    ap.add_argument("--clis", nargs="*", default=[],
                    help="CLI names to verify; auto-derived from --commands if omitted")
    ap.add_argument("--mcp", nargs="*", default=[],
                    help="MCP servers the task plans to use (echoed for Claude to probe)")
    ap.add_argument("--cwd", default=os.getcwd(), help="project root for settings discovery")
    ap.add_argument("--mode", choices=["default", "manual", "acceptEdits", "plan", "auto",
                                       "dontAsk", "bypassPermissions"],
                    help="the session's current permission mode; defaults to settings defaultMode")
    args = ap.parse_args()

    cwd = Path(args.cwd).resolve()
    files = discover_settings(cwd)
    perms, default_mode = load_permissions(files)
    mode = args.mode or default_mode
    if mode == "manual":
        mode = "default"
    classify_all_shell = load_classify_all_shell()
    hooks = load_bash_hooks(files)

    rows = []  # (category, target, status, reason)

    for cmd in args.commands:
        hook = hook_decision(cmd, hooks)
        status, reason = classify_command(cmd, perms, mode, classify_all_shell, hook)
        rows.append(("perm", cmd, status, reason))

    clis = list(dict.fromkeys(args.clis or extract_clis_from_commands(args.commands)))
    for cli in clis:
        status, reason = check_cli(cli)
        rows.append(("cli", cli, status, reason))

    # ---- report ----
    print("PRE-FLIGHT CHECK")
    print(f"  cwd: {cwd}")
    print(f"  settings: {', '.join(str(f) for f in files) or '(none found)'}")
    mode_source = "--mode" if args.mode else "settings defaultMode; pass --mode for the live session"
    print(f"  mode: {mode} ({mode_source})")
    print(f"  autoMode.classifyAllShell: {classify_all_shell}")
    print(f"  Bash hooks: {', '.join(c for c, _ in hooks) or '(none)'}")
    print()
    if rows:
        width = max(len(t) for _, t, _, _ in rows)
        for cat, target, status, reason in rows:
            print(f"  [{ICON[status]}] {cat:4} {target:<{width}}  {reason}")
    else:
        print("  (no commands or CLIs to check)")

    if args.mcp:
        print()
        print("  MCP servers to probe (Claude must verify — script cannot call MCP):")
        for s in args.mcp:
            print(f"    - {s}: make ONE cheap read (whoami/list) before relying on it")

    reds = [r for r in rows if r[2] == RED]
    ambers = [r for r in rows if r[2] == AMBER]
    print()
    if reds or ambers:
        print(f"VERDICT: HALT — {len(reds)} red, {len(ambers)} amber. "
              "Do not fan out until resolved.")
        sys.exit(1)
    print("VERDICT: deterministic checks passed. "
          "Probe any MCP servers above, then proceed.")
    sys.exit(0)


if __name__ == "__main__":
    main()
