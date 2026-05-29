#!/usr/bin/env python3
"""Deterministic pre-flight checks: permission rules + CLI presence/auth.

This script handles the parts a pre-flight check can verify WITHOUT model
judgement: whether planned bash commands would be allowed/denied/prompted by
the settings files, and whether required CLIs exist and are authenticated.

MCP connectivity is NOT checked here — only Claude can call MCP tools — so any
servers passed via --mcp are echoed back as a reminder for Claude to probe.

Exit code: 0 = all green. 1 = at least one RED (denied / missing / auth-failed)
or AMBER (would prompt). Fail-fast callers should halt on a non-zero exit.

Usage:
  preflight.py --commands "git commit" "npm run build" --clis gh jq \
               --mcp Figma Atlassian --cwd /path/to/project
"""

import argparse
import json
import os
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


def parse_bash_rule(rule: str):
    """Extract the matchable spec from a permission rule.

    Returns (kind, spec) where kind is:
      'all'    -> bare `Bash`, matches any command
      'prefix' -> `Bash(foo:*)`, command must start with `foo`
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
    return False


def classify_command(command: str, perms, default_mode: str):
    """Return (status, reason). Deny wins, then allow, then ask, else unlisted."""
    if default_mode == "bypassPermissions":
        return (GREEN, "defaultMode=bypassPermissions (all commands allowed)")
    for rule, src in perms["deny"]:
        if cmd_matches(command, rule):
            return (RED, f"matched DENY `{rule}` ({src})")
    for rule, src in perms["allow"]:
        if cmd_matches(command, rule):
            return (GREEN, f"matched ALLOW `{rule}` ({src})")
    for rule, src in perms["ask"]:
        if cmd_matches(command, rule):
            return (AMBER, f"matched ASK `{rule}` ({src}) — will prompt")
    if default_mode == "acceptEdits":
        # acceptEdits auto-accepts edits but still prompts for other tools incl. Bash
        return (AMBER, "no matching rule (defaultMode=acceptEdits still prompts for Bash)")
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
    args = ap.parse_args()

    cwd = Path(args.cwd).resolve()
    files = discover_settings(cwd)
    perms, default_mode = load_permissions(files)

    rows = []  # (category, target, status, reason)

    for cmd in args.commands:
        status, reason = classify_command(cmd, perms, default_mode)
        rows.append(("perm", cmd, status, reason))

    clis = list(dict.fromkeys(args.clis or extract_clis_from_commands(args.commands)))
    for cli in clis:
        status, reason = check_cli(cli)
        rows.append(("cli", cli, status, reason))

    # ---- report ----
    print("PRE-FLIGHT CHECK")
    print(f"  cwd: {cwd}")
    print(f"  settings: {', '.join(str(f) for f in files) or '(none found)'}")
    print(f"  defaultMode: {default_mode}")
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
