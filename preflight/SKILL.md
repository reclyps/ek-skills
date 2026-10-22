---
name: preflight
description: Runs pre-flight permission, CLI, and MCP health checks for the tools a task will use, then HALTS with a clear report if anything would fail — before any parallel explores, subagents, or MCP calls launch. Use when invoked as /preflight, when the user mentions a preflight or health check, or before fanning out parallel work that depends on permissions, MCP servers, or external CLIs.
---

# Pre-flight

Verify the tools a task needs are available **before** committing to expensive
or parallel work. Fail fast: if any check is red or amber, halt and report — do
not launch explores, subagents, or MCP calls until the user resolves it.

A mid-flight permission prompt or a dead MCP server wastes a whole parallel
batch. This trades ~10 seconds of checks for that.

## When to run

- The user invokes `/preflight`, or asks for a health/permission check.
- **Before fanning out** parallel Explore agents, subagents, or batched MCP/bash
  work — especially anything depending on permissions, MCP servers, or CLIs.
- Skip for trivial single-tool turns; the check overhead isn't worth it there.

## Workflow

### 1. Build the manifest

List only what **this task** will actually use — not the world:

- **Bash command families** the task will run (`git commit`, `npm run build`, `gh pr create`).
- **External CLIs** those commands need (`gh`, `jq`, `gcloud`, `aws`).
- **MCP servers** the task will call (Figma, Atlassian, …).
- **Fan-out scope** — roughly how many parallel agents, and what each needs.

### 2. Run the deterministic checks

`preflight.py` covers permissions + CLI presence/auth (it cannot call MCP). Pass
the manifest; `--cwd` should be the **project root** so it finds the project's
`.claude/settings.local.json` allowlist. Pass `--mode` as the session's
**current** permission mode (`auto` when the system context says auto mode is
active); the outcome depends on it, and settings `defaultMode` is often not the
live mode:

```bash
python3 ~/.claude/skills/preflight/scripts/preflight.py \
  --commands "git commit" "npm run build" "gh pr create" \
  --clis gh jq \
  --mcp Figma Atlassian \
  --cwd "$(pwd)" --mode auto
```

It evaluates each command the way Claude Code does: deny rules, then Bash
PreToolUse hooks and ask rules (both prompt in every mode, auto included), then
the mode. In auto mode with `autoMode.classifyAllShell`, allow rules are
suspended and the classifier reviews the command without a prompt.

It reports each item as **GREEN** (runs without a prompt / present+authed),
**AMBER** (would prompt), or **RED** (denied / missing / auth failed), and exits
non-zero if any item is amber or red. Permission matching is a heuristic that
errs conservative — it reports a prompt rather than assuming an allow.

**Always invoke the script by its installed path, never as relative
`scripts/preflight.py`.** The cwd is the project root, not the skill directory,
so the relative form only works if you happen to be sitting in the skill folder.
On Windows: `python3 "$env:USERPROFILE\.claude\skills\preflight\scripts\preflight.py"`.
If the skill is installed somewhere else, locate it first
(`ls ~/.claude/skills/preflight/scripts/`) rather than guessing.

### 3. Probe MCP servers yourself

The script lists declared MCP servers but cannot test them. For each one the
task needs, make **one** cheap read (e.g. `whoami`, a list, `get_metadata`)
**sequentially, before any parallel work** — per the user's standing rule that
MCP connectivity is verified alone before batching. A failed or unauthenticated
response is RED.

### 4. Verdict

- **All green** → state "preflight passed" briefly, then proceed and fan out.
- **Any amber or red** → **HALT.** Do not launch parallel work. Report a table:

  | Check | Status | Why | Fix |
  |-------|--------|-----|-----|

  - **Amber from a hook or ask rule** → the gate is deliberate (a write, a
    secret read, a destructive git form). Don't propose an allow rule: allow
    can't override ask, and widening the gate is the user's call, not a fix.
    Offer instead: run that step in the foreground so the user can approve it,
    hand the user the exact command to run, or drop it from the plan. For a
    secret-printing read, give a user-run command that extracts only the
    non-secret fragment the task needs.
  - **Amber with no matching rule (default or acceptEdits mode)** → give the
    exact read-only rule to add (e.g. `Bash(npm run build:*)` in
    `.claude/settings.local.json`). In auto mode with `classifyAllShell`, allow
    rules have no effect, so don't propose them there.
  - **Red from a deny rule** → the user runs that step; hand over the command.
  - **Do not edit `.claude/**` yourself** — propose changes and let the user
    apply them (or route via `/update-config`).
  - **Dead/unauthed MCP** → trigger its re-auth flow if one exists, else tell
    the user which server and what failed.
  - **Missing/unauthed CLI** → name the install or auth command.

  Then wait for direction. Fail-fast means stopping here, not working around it.

## Notes

- The check is advisory, not a guarantee — permission matching is heuristic and
  MCP/auth state can change after the probe. Treat a clean preflight as "very
  likely clear," not "certified."
- If the project root differs from cwd (monorepo subdir, etc.), pass the dir
  holding `.claude/` as `--cwd` so the right allowlist is read.
- Background subagents can't answer prompts, so an amber step there becomes a
  denial. Keep background agents to green steps.
- The script runs Bash PreToolUse hooks from settings files with a synthetic
  payload; plugin hooks aren't checked.
