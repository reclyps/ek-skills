---
name: workstream
description: "Give any piece of work, from a single-session task to a multi-month epic, its own folder holding a small state file and every working file the work produces, so it stays organized and resumable. Three modes: init creates the workstream from a template, park records where things stand at the end of a session, resume picks it back up in a fresh session. Use when the user invokes /workstream."
argument-hint: "init <name> | park [name] | resume [name]"
disable-model-invocation: true
---

# Workstream

A workstream is a folder for one piece of work, of any size. It holds the work's state and history plus every file the work produces. Sessions stay short and single-purpose, and the folder holds the continuity.

```
<workstreams-dir>/<name>/
├── STATE.md      # where things stand now; rewritten in place, read at every resume
├── LOG.md        # what each session did; append-only, read only when a "why" is needed
├── plans/        # per-ticket or per-phase plans
├── research/     # findings written by research or review agents
└── ...           # any other working file: drafts, payloads, scripts, exports
```

**Every working file goes in the folder.** While a workstream is active in a session, put each file the session creates for this work inside its folder, never loose in the workspace, unless the file belongs in the repository itself. Plans and research use their subfolders; anything else goes at the folder root or in a subfolder named for what it holds.

## Route by mode

| Call | Do |
|---|---|
| `/workstream init <name>` | Follow [init.md](init.md) |
| `/workstream park [name]` | Follow [park.md](park.md) |
| `/workstream resume [name]` | Follow [resume.md](resume.md) |
| `/workstream` with no mode | List workstreams: for each folder, its `Updated` and `Status` lines. Then ask which mode |

When `[name]` is omitted: use the workstream already resumed or initialized in this session; otherwise the only one whose status is not `done`; otherwise list them and ask.

## Locate the workstreams directory

Run `scripts/locate.sh [--root <dir>] [name]`. It prints the absolute path. Pass `--root` when either of these names a location:

1. A path in the user's arguments.
2. A workstreams location stated in the project's or user's agent instructions.

Otherwise the script defaults to `.workstreams/` at the root of the repository's main checkout, so every worktree of a repo shares the same workstreams, and outside a git repository it uses the current directory. A relative `--root` resolves against the same base.

## Rules for STATE.md

These hold in every mode, and `scripts/check.sh <path-to-STATE.md>` enforces the mechanical ones.

- **Keep STATE current.** It describes now; what a session did goes in LOG. Rewrite sections in place and never accumulate dated "this session changed" entries.
- **At most 150 lines.** Over the cap, move detail into `plans/` or `research/` and link it, or drop what is no longer true.
- **Re-check rather than copy.** For anything another system owns (ticket status, PR state, build or gate results, cloud config), record a read-only command under *Live checks* rather than its value. When a value must be copied, append `(as of YYYY-MM-DD)`.
- **Every blocker names an owner and a resume trigger**: the event that lets work on it start again.
- **Every next action names a suggested model tier and effort**, so the next session starts on the right one:
  - *deep*: the strongest reasoning model available, for design decisions and ambiguous trade-offs, and for security-sensitive review
  - *standard*: implementation from an agreed plan
  - *light*: the fastest, lowest-cost model, for status checks, polling, doc lookups, and mechanical edits

  Effort (high / medium / low) applies where the harness supports it.
- **Decisions are not relitigated.** A recorded decision changes only when the user says so.
- **Write only what a reader can't derive.** Leave out anything git, the tracker, or a CLI can answer.

## Status

`Status:` in STATE is one of `active`, `blocked` (every next action waits on a blocker), or `done` (the session's latest state shows nothing left to do). Finishing needs no special step; park records `done` when that is true.
