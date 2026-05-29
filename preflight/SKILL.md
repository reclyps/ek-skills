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

`scripts/preflight.py` covers permissions + CLI presence/auth (it cannot call
MCP). Pass the manifest; `--cwd` should be the **project root** so it finds the
project's `.claude/settings.local.json` allowlist:

```bash
python3 scripts/preflight.py \
  --commands "git commit" "npm run build" "gh pr create" \
  --clis gh jq \
  --mcp Figma Atlassian \
  --cwd "$(pwd)"
```

It reports each item as **GREEN** (allowed / present+authed), **AMBER** (would
prompt — no matching allow rule), or **RED** (denied / missing / auth failed),
and exits non-zero if any item is amber or red. Permission matching is a
documented heuristic that errs conservative — it reports a prompt rather than
assuming an allow.

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

  - **Permission amber/red** → give the exact rule to add (e.g.
    `Bash(npm run build:*)` in `.claude/settings.local.json`). **Do not edit
    `.claude/**` yourself** — propose it and let the user apply it (or route via
    `/update-config`).
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
