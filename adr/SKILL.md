---
name: adr
description: Write Architecture Decision Records (ADRs) that capture technical decisions, alternatives considered, and consequences. Use when user asks to write an ADR, document a technical decision, or mentions "architecture decision record".
---

# Write an ADR

## Overview

Write an Architecture Decision Record following the format established by Michael Nygard and refined by Martin Fowler. ADRs are short documents (1-2 pages) that capture a single technical decision and the context behind it. A full ADR also covers alternatives considered and consequences, but those sections can be dropped or shortened when the user's framing calls for it (see step 1).

Reference material:
- [Michael Nygard's original ADR proposal](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [Martin Fowler on ADRs](https://martinfowler.com/bliki/ArchitectureDecisionRecord.html)
- [Scaling Architecture Conversationally — ADR section](https://martinfowler.com/articles/scaling-architecture-conversationally.html#adr)
- [Microsoft Well-Architected — Maintain an ADR](https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record)

## Workflow

### 1. Assess available context and honor user overrides

Check the conversation for prior discussion of the decision. If substantial context exists (problem discussed, options explored, a choice made), move to step 3 — draft from conversation context. If not, move to step 2.

**Scope notes** — guidance to surface if useful, not gates. If the user asks for an ADR, write it.
- ADRs are most valuable for decisions that shape system structure, affect key quality attributes, or are hard to reverse.
- If the decision has distinct phases (short/mid/long-term), consider one ADR per phase rather than bundling.
- Retroactive ADRs for existing systems are fine and often valuable.

**Honor overrides from the user's prompt.** The default template and workflow below are a starting point, not a contract. When the user specifies how the ADR should be shaped, adjust the template, the interview, and the review step to match. Scope the interview to what the ADR the user actually wants will contain. When in doubt, err toward honoring the user's framing rather than defending the default.

Overrides can touch any dimension of the document. Categories to listen for:

- **Scope** — which sections appear. *"Skip Alternatives", "add a Rollout Plan section", "include Risks separate from Consequences".*
- **Emphasis** — which sections carry the weight. *"Focus on rationale", "the decision is the headline, everything else is brief".*
- **Structure / format** — how the document is organized. *"Use a Y-statement", "reorder so Decision comes first", "bullet Consequences by stakeholder".*
- **Status / lifecycle** — what state the decision is in and how it relates to other ADRs. *"Status is Accepted, don't ask", "this supersedes ADR-0012", "mark Proposed but flag open questions".*
- **Audience** — who the ADR is written for. *"Write for leadership, not the team", "assume no codebase context".*
- **Tone** — how assertive or tentative. *"More tentative — we're not fully committed", "this is settled, write it that way".*

An override typically takes the form of either an explicit instruction (*"skip X"*, *"focus on Y"*) or a framing statement about the decision itself (*"the decision is already made"*, *"we haven't decided, we're documenting the options"*) that implies a shape. Treat both as overrides.

### 2. Interview the user

Scope the interview to the sections the final ADR will actually contain (per step 1 overrides). For a full ADR, gather:

- **The problem**: What situation or need prompted this decision?
- **The decision**: What are you choosing to do? (Use "We will..." framing)
- **Alternatives**: What other options were seriously considered? Why were they ruled out?
- **Consequences**: What follows from this decision — tradeoffs, operational requirements, costs, future options opened or closed?

If the user signals uncertainty about the decision ("we think...", "probably", "for now"), ask whether they want a **Confidence** note captured so future readers know the decision was provisional.

Ask focused follow-up questions to fill gaps. Don't ask about things already covered, and don't ask about sections the user has explicitly dropped. Push on weak areas — vague alternatives, missing consequences, unstated assumptions — but only for sections that will appear in the final doc.

### 3. Draft the ADR

Write the ADR using the structure below as a **default template**. Sections are adjustable — omit, collapse, expand, reorder, or add to match the overrides from step 1 and the material you actually gathered. Context and Decision are the only sections that should almost always appear; everything else is shaped by what the decision needs and what the user asked for.

```markdown
# ADR: [Decision Title]

**Status:** [Proposed|Accepted|Superseded|Deprecated]   ← omit if the user has said status is not relevant
**Supersedes:** [link to prior ADR]   ← include only when this ADR replaces an earlier one

## Context

[The problem, forces at play, and why a decision is needed. Neutral, factual tone. This is where the "why" lives when Alternatives is dropped or shortened.]

## Decision

[What we will do. Active voice, "We will..." framing. Specific enough to act on.]

**Confidence:** [Low|Medium|High] — [brief why]   ← optional; include when the decision is provisional or carries known unknowns

## Alternatives Considered   ← omit if no alternatives were seriously weighed, or the user has asked to skip

[Each alternative as a bold-titled paragraph. What it is, why it was considered, why it was not chosen.]

## Consequences   ← keep unless the user has explicitly scoped them out

[Bulleted list of implications — operational requirements, costs, risks, extensibility, tradeoffs. Include both positive and negative consequences.]
```

### 4. Review with user

Present the draft and ask if anything needs adjustment — missing context, incorrect framing, or gaps in any section that made it into the doc. Do not prompt the user to add back sections they have explicitly dropped.

### 5. Write to file

- If the user has already specified an output path, use it.
- **Otherwise ask where to write it — always, before writing.** Do not infer a location from the repo's layout: an existing `docs/adr/` folder is not consent to add a tracked, reviewable document to it. Offer an untracked working location (e.g. an ignored `local/`) alongside the repo's ADR folder, and let the user pick.
- Generate a descriptive kebab-case filename from the title (e.g., `adr-secret-expiry-notifications-via-event-grid.md`) unless the user specifies a name.
- Default status to **Proposed** unless the user has specified otherwise (either explicitly or through framing — see step 1).
- **Superseding an earlier ADR**: if this decision replaces a previous one, write a new file rather than editing the old one. Add a `Supersedes: [link to prior ADR]` line near the status, and ask the user whether to update the prior ADR's status to `Superseded` with a backlink to this one.

### 6. Prose pass

The file exists now, so run the prose pass over it.

1. `scripts/check-prose.sh <file>` — see [PROSE.md](PROSE.md) for what each flag indicates. Flags
   default to fix; keep one only deliberately, and say which and why.
2. Hand the file to a subagent briefed with [REWRITE.md](REWRITE.md), pinned to Sonnet, telling it
   the document is an ADR so it preserves the format. Then run the linter again on
   the result.

The ADR template's section headings are fixed by convention. The rewriter must not rename
`Context`, `Decision`, `Alternatives Considered` or `Consequences`, and must not merge them. If the
rewrite changes anything a reader would act on differently, show the user before you stop.

The `prose-pass` skill is the same machinery if you want it on its own.

## Writing guidelines

- **Brevity**: Keep to 1-2 pages. Link to supporting material rather than embedding it.
- **Tone**: Write as if speaking to a future team member who wasn't in the room. Neutral, factual context; assertive decision; honest consequences.
- **Active voice**: "We will..." not "It was decided that..."
- **Specificity over vagueness**: Name the technologies, services, and tradeoffs concretely.
- **Consequences should be honest (when included)**: Include operational burdens, risks, and limitations — not just benefits.
- **Alternatives should be fair (when included)**: Explain why each was considered, not just why it lost. Acknowledge their strengths.
- **Append-only log**: Once an ADR is accepted, don't rewrite it. If the decision changes, supersede it with a new ADR and link the two. This preserves the history of the team's thinking.

