---
name: cupid
description: Evaluate code against CUPID software design principles (Composable, Unix Philosophy, Predictable, Idiomatic, Domain-Based). Use when user asks to evaluate code quality, review a feature/PR/branch against CUPID, or mentions "cupid".
---

# CUPID Evaluation

Evaluate a target against the CUPID principles defined in [CUPID-PRINCIPLES.md](CUPID-PRINCIPLES.md).

## Defaults (all overridable via prompt)

- **Target:** whole codebase if unspecified
- **Principles:** all 5 evaluated
- **Output:** rendered in terminal (write to file if user requests)
- **Ratings:** Strong / Moderate / Weak per principle (see [Rating semantics](#rating-semantics))
- **Recommendations:** scaled to the size and scope of what's being reviewed — no minimum, no padding (see [Scoping recommendations](#scoping-recommendations))
- **Surrounding code:** read imports, consumers, config, and the immediate surroundings of any code you'd recommend changing — verify the recommendation fits the existing context before proposing it

## Target resolution

1. **Directory or file paths** — evaluate those files directly
2. **PR number** — run `git diff main...HEAD --name-only` (or the PR's base) to get changed files. Evaluate the diff itself plus the immediate surroundings (the enclosing function/component, the file's exports, direct callers) needed to judge the changes.
3. **Branch name** — same as PR, using `git diff main...<branch> --name-only`
4. **No target specified** — evaluate the whole codebase

For PR/branch targets, the review is about the *changeset*, not the full state of the touched files. The scale of recommendations must match the scale of the PR's changes — a 20-line bugfix does not warrant a module-level restructure.

## Investigation workflow

Scale the investigation to the target. A full Explore sweep on a 3-file PR tends to surface concerns that are out of scope for the changeset.

If you are already running inside a subagent (e.g. a caller delegated this evaluation to an isolated context), skip the internal Explore fan-out and read the target directly — you already have a clean, scoped context, and nesting further agents adds cost without benefit.

- **Small PR / file-level review:** read the diff and its immediate surroundings directly. Skip the parallel Explore agents unless the changeset genuinely reaches across many files.
- **Larger PR, directory, or whole codebase:** launch the two parallel Explore agents below.
- **Very large target where analytical depth is the bottleneck (opt-in):** after the two context agents return, optionally fan out one evaluator agent per CUPID principle (5 total) — each receives the gathered context plus the principle's definition from [CUPID-PRINCIPLES.md](CUPID-PRINCIPLES.md) and produces a finished section in the [Evaluation structure](#evaluation-structure) format. The main thread then stitches the five sections together and writes the summary table + highest-impact improvements. Use this mode only when the user asks for it or when synthesis in a single thread would clearly be the bottleneck — it trades redundant reads and possible cross-section style drift for genuinely parallel analysis.

**Agent 1 — Target code:**
> Thoroughly explore [target]. Read representative files across the target. Investigate: component/module structure, naming conventions, API surface area, dependency patterns, type usage, test coverage, error handling, domain modeling, file organization. Read actual file contents, not just names.

**Agent 2 — Surrounding context:**
> Explore code that interacts with [target]. Find: who imports from the target, what the target imports, relevant config/types/constants, how the target fits into the broader architecture. Focus on composition boundaries and coupling patterns.

If evaluating the whole codebase, Agent 2 should focus on cross-cutting concerns: config, routing, state management, shared utilities, theming, and build setup.

## Scoping recommendations

Recommendations must be proportionate to what the user is actually changing. A reviewer who asks for a 3-line diff should not be handed a 300-line refactor.

- **Match scale to changeset.** For a small PR, recommendations should be small. A recommendation to restructure an enclosing module is almost always out of scope for a targeted change within it.
- **No minimum count.** If a principle is well-handled within the changeset, say so and move on. Do not pad to hit a number.
- **Verify context before recommending.** Before proposing a change, read enough surrounding code to confirm the change is both needed and well-formed. Example: don't recommend wrapping a call in `try/catch` without first checking whether the callee already handles errors — the right recommendation may be to handle its returned error value, not to add another layer of exception handling. The same applies to validation, logging, null checks, memoization, and other "add a layer" suggestions.
- **In-scope vs. out-of-scope (PR/branch reviews).** Recommendations should stay within the diff and its immediate surroundings. If you notice a meaningful CUPID issue in code the PR did *not* introduce or modify, report it separately under **Observations (pre-existing)** so it is visible but clearly not the PR author's responsibility to fix here.

## Rating semantics

- **Codebase / directory / file targets:** ratings reflect the absolute state of the target.
- **PR / branch targets:** ratings reflect the *direction of travel* — did this changeset move the code toward or away from the principle? **Strong** = clear improvement, or maintains strong quality while adding value. **Moderate** = mixed or neutral. **Weak** = regression. Pre-existing issues in touched files do not pull the rating down unless the PR makes them worse.

## Evaluation structure

For each principle, produce:

### [Letter] — [Principle Name]
**Rating: [Strong / Moderate / Weak]**

- Evidence from the code (cite specific files/patterns, with line ranges where useful)
- Where the target (or changeset) excels
- Where the target (or changeset) falls short
- Concrete, actionable recommendations — as many as the target genuinely warrants, and no more. If nothing meaningful is needed for this principle, say so explicitly.

For PR/branch targets, optionally add:
- **Observations (pre-existing):** CUPID issues visible in touched files that the PR did not introduce. Flag these clearly so the author can distinguish them from PR-scoped recommendations.

Then produce:

### Summary Table

| Principle | Rating | Key Evidence |
|-----------|--------|--------------|
| **C** Composable | ... | ... |
| **U** Unix Philosophy | ... | ... |
| **P** Predictable | ... | ... |
| **I** Idiomatic | ... | ... |
| **D** Domain-Based | ... | ... |

### Highest-Impact Improvements

The most valuable cross-cutting actions, ranked by impact. Count is flexible — include only those that genuinely rise to the "highest impact" bar, and that stay within the scope of what's being reviewed. For a small, tight PR this section may be short or omitted; for a whole-codebase review it may be longer.

## File output

If the user requests file output, write the evaluation to the path they specify (or default to `cupid-evaluation.md` in the project root). Do not create a file unless requested.
