---
name: readability-review
description: Review the files a branch, diff, or PR adds or reshapes against the readability rules in READABILITY-RULES.md (entry point first, happy path as named steps, plumbing in its own module), reporting each finding with file and line, the rule it breaks, and a structural fix. Use when the user asks to review readability, asks whether code follows their readability rules, points this at a PR or branch they are reviewing, or says an entry point or core flow is hard to find. Reports only and never edits.
---

# Readability Review

Check whether each file a change touches lets a reader find its entry point and follow the happy path, and report. The rules live in [READABILITY-RULES.md](READABILITY-RULES.md) next to this file — the same file CLAUDE.md imports, so there is one copy. Read it first; it is the rubric. When delegating to a subagent, resolve its absolute path and pass it along.

## Scope

- **Target:** what the caller names — a PR, branch, ref range, or paths. A PR resolves to its source and target branches through the host's CLI; fetch both before diffing.
- **Base:** the PR's target branch, or the ref the caller names. Otherwise the upstream default branch. On a stacked branch, use the parent. If unclear, ask.
- **Files:** source the change adds, plus files whose entry point or layout it changes. A file it only edits inside one function is out of scope unless the edit buries the entry point. Skip tests, generated code, config, docs.
- **Unit is the file, not the line.** Read each in-scope file whole at the head revision; a diff hunk can't show what sits above an entry point.

## Workflow

1. **List files.** `git diff --name-status <base>...<head>`, filtered to scope. Write the list to a scratch or `local/` file if long.
2. **Find each file's entry point(s):** the export, `main`, component, handler, or public type a caller reaches first. A file of peer utilities with no entry point is fine; say so and move on.
3. **Apply the test** from the rules: read only the entry point. Can you say what it does, in order, without opening a helper? Note what precedes it and how far down it sits.
4. **Check local idiom before flagging layout.** Look at lint config (define-before-use rules) and neighboring files. If the layout is forced or matches the codebase, the fix is where code lives, not reordering. Record the evidence.
5. **Classify** against the rules. Tells:

   | Rule | Tells |
   | --- | --- |
   | Entry point buried | Entry point past the first screen; constants, types, or helpers stack above it |
   | Mixed levels | Entry point interleaves named steps with raw detail: string building, request setup, loops over low-level fields |
   | Plumbing inline | Escaping, transport, retries, serialization, or platform glue defined in a domain file |
   | Interleaved cases | One function branches on kind and handles every case inline |
   | Handling pushed up | Caller unwraps or re-checks a result its step could have resolved |
   | Over-extraction | One-line helpers named for their body; signatures as heavy as bodies; code that must be read together split apart |

6. **Report.**

## Output

Group by file, worst first (buried entry point and mixed levels before the rest). One row per finding:

| Where | Problem | Suggested fix |
| --- | --- | --- |
| `path/file.ts:40` | Which rule, with what the reader must get past | The structural move: "move `a`, `b` to a new `x` module", "one function per case", "inline `c`" |

Then:

- **Left alone (local idiom):** each pattern and the evidence.
- **Summary:** files checked, findings, and the one or two worth fixing first.

Direct invocation renders in the terminal. When delegating, use a mid-tier model at default effort; the top tier for large or cross-module changes. The smallest tier misses abstraction-level calls. A delegated run writes the report under `local/` and returns a summary under ~300 words plus the path.

Do not edit, and do not post to the PR. Offer to apply the fixes or draft PR comments; the caller decides.
