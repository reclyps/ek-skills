---
name: docs-review
description: Review the durable Markdown docs a branch, diff, or PR adds or edits against the doc rules in DOC-RULES.md, reporting each violation with file and line, the rule it breaks, and a suggested rewrite. Use when the user asks to review, check, or audit docs, READMEs, ADRs, or contributor guides, asks whether docs follow their rules, or when a branch review or ticket workflow reaches its docs check. Reports only and never edits.
---

# Docs Review

Check the durable docs a change adds or edits against the rules, and report. The rules live in [DOC-RULES.md](DOC-RULES.md) next to this file — the same file CLAUDE.md imports, so there is one copy. Read it first; it is the rubric. When delegating to a subagent, resolve its absolute path and pass it along.

## Scope

- **Target:** Markdown a change adds or edits: `docs/`, agent-instruction folders, READMEs, ADRs, contributor guides. Review each touched section; read the whole file for context.
- **Base:** the PR's target branch, or the ref the caller names. Otherwise the upstream default branch. On a stacked branch, use the parent. If unclear, ask.
- **Out:** code comments (`comment-review`), model prose tics (`prose-pass`), and artifacts for readers who can't query the system (Jira tickets, PR descriptions).

## Workflow

1. **List files.** `git diff --name-status <base>...<head> -- '*.md'`, filtered to scope.
2. **Read the diff, then each file whole.** Pre-existing text is out of scope unless the change makes it false.
3. **Verify specifics against the code.** Check each named path, command, flag, symbol, rule or config value exists as written, and each claim about another file still holds. A doc that is wrong is worse than one that is thin.
4. **Classify** against the rules. Tells:

   | Rule | Tells |
   | --- | --- |
   | Statistic | Counts, percentages, "roughly", "about", version numbers outside a procedure |
   | Another module as fact | Names a job, service, or file and says what it does |
   | Narrates the change | "now", "no longer", "previously", "added for" |
   | Restates the source | Copied values, listings, or tables the code already has |
   | Time-bound, no owner | "currently", "not licensed", with nobody named |
   | Drifting examples | "A, B, C, …" where a category would do |
   | Duplicated fact | Same rule in two docs; grep before flagging |
   | Wrong | Name, command, or claim that doesn't match the code |

5. **Check local idiom** before flagging a pattern: if neighboring docs share the shape, list it under "Left alone" with the evidence.
6. **Report.**

## Output

Group findings by rule, most consequential first (wrong, then another-module, then the rest). One row per finding:

| Where | Problem | Suggested fix |
| --- | --- | --- |
| `path/doc.md:40` | What breaks the rule, quoting the words at fault | The rewrite, or "Drop" |

Then **Left alone (local idiom)** and a **Summary**: sections checked, findings, the one or two worth fixing first.

Direct invocation renders in the terminal. A delegated run writes the report to the output path the brief names, else to the working-files location in the user's agent instructions, and returns a summary under ~300 words plus the path. With neither, it returns the full report. Use a mid-tier model.

Do not edit. Offer to apply the fixes; the caller decides.
