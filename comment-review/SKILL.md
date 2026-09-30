---
name: comment-review
description: Review the code comments a branch or diff adds against the comment rules in COMMENT-RULES.md, reporting each violation with file and line, the rule it breaks, and a suggested rewrite. Use when the user asks to review, check, or audit comments, asks whether comments follow their rules, or when a branch review or ticket workflow reaches its comment check. Reports only and never edits.
---

# Comment Review

Check every comment a change adds against the rules, and report. The rules live in [COMMENT-RULES.md](COMMENT-RULES.md) next to this file — the same file CLAUDE.md imports, so there is one copy. Read it first; it is the rubric for everything below. When delegating to a subagent, resolve its absolute path and pass it along.

## Scope

- **Target:** the comments the change *adds* (new and rewritten lines). Pre-existing comments are out of scope unless the change makes one false.
- **Base:** the ref the caller names. Otherwise the upstream default branch. On a stacked branch, use the parent branch, not the default — otherwise the parent's comments get reviewed twice. If the parent is unclear, ask.
- **Files:** source, tests, SQL, scripts. Not Markdown docs; their rules differ.

## Workflow

1. **Extract.** From the repo root:
   ```bash
   <this-skill-dir>/scripts/extract-comments.py <base> [paths…] > <scratch>/comments.txt
   ```
   Write to a scratch or `local/` file, not the transcript. Each block is `### S|T path:start-end` (S source, T test) followed by its text. The count goes to stderr.
2. **Read the list, then the code around anything doubtful.** A comment's truth depends on the code under it; the list alone can't show a comment the change made stale.
3. **Classify each block** against the rules. What to look for:

   | Rule | Tells |
   | --- | --- |
   | Narrates the change | "now", "previously", "historically", "old", "former", "no longer", ticket IDs, plan or session refs |
   | Describes another module | Names another class, service, or library and says what it does ("X logs its own failures", "the SDK doesn't encode…"). Fails the "stays true if a different file changed" test |
   | Restates the code or name | Paraphrases the next line, the identifier, or the type signature |
   | Too long | Past ~3 lines without a contract that needs the room; often repeats a doc |
   | Workaround without a link | Explains a third-party quirk with no issue or doc link. Suggest adding one; never invent a URL |
   | Stale | Contradicts the code it sits on (says "never throws" above a try/catch). Most often left by an edit that changed behavior without re-reading the comment |
   | Comments around unclear code | Explains what a name or extraction should |

   Why, warning, workaround and contract comments that fit the budget pass. Say nothing about them.
4. **Check local idiom before flagging a pattern.** If neighboring files use the same shape (test section banners, `@desc` tags, one-line component summaries), list it under "Left alone" with the evidence (e.g. "70 test files use them") rather than as a finding.
5. **Report.**

## Output

Group findings by rule, most consequential first (stale and another-module before restatement). One row per finding:

| Where | Problem | Suggested fix |
| --- | --- | --- |
| `path/file.ts:12-15` | What breaks the rule, quoting the words at fault | The rewrite, or "Drop" |

Then:

- **Left alone (local idiom):** each pattern and the evidence.
- **Summary:** blocks checked, findings, and the one or two worth fixing first.

Direct invocation renders in the terminal. When running as a delegated subagent, write the report under `local/` and return a summary under ~300 words plus the path.

Do not edit. Offer to apply the fixes; the caller decides.
