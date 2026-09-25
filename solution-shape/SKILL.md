---
name: solution-shape
description: Agree the shape of a change with the user before acting — from a bugfix's approach to a feature's modules, seams, and key decisions — so the user makes the decisions and can explain the work. Use when the user invokes /solution-shape or asks to sketch a solution, shape it, or agree an approach first. When the user is heading toward an implementation plan for non-trivial work and no shape has been agreed, offer it in one line, along the lines of "sounds like we're heading toward a plan — run /solution-shape to decide the shape together first?", and start only on a yes.
---

# Solution Shape

Agree the napkin sketch of a change with the user before anyone writes a plan or code. This skill produces the shape and stops; planning, tickets, and code are other skills' jobs.

## Napkin resolution

Everything in this skill stays at napkin resolution: modules, one-line responsibilities, arrows, seams, trade-offs. File paths, method signatures, SQL, and edge-case handling belong to the plan — when one matters to the shape, record it as an open question and move on. If a turn starts filling with those, zoom back out.

The user makes the decisions. Claude proposes, recommends, and lays out trade-offs; a decision is settled only when the user has said so.

## The pitch

Every run, at every size, produces a **pitch**: one or two plain sentences on what changes and why, in words a teammate reading the pull request would follow. It is how the user understands work they didn't write by hand, and the seed of the PR description. It is never skipped, even when there is only one sensible path. Restate it whenever the shape changes.

## Check the context

Before anything else, look at what the conversation already holds for this work. A diagnosis is fine; it describes the problem. A proposed fix or plan, code already written for the change, or implementation bodies read well beyond the problem will anchor the sketch. If you see any of those, say so in one line, naming what is there, and offer two ways on:

- **Continue** — treat the existing proposal as one candidate among the others, with no head start.
- **Fresh start** — write a short handoff for a new session: the task, the diagnosis, and the constraints, leaving the proposed solution behind.

Go on with whichever the user picks.

## Size the work

Before framing, choose a branch and name it in one line; the user can override.

- **Small** — a bugfix or contained change that stays inside one module or follows an existing pattern.
- **Large** — new modules, a changed seam or contract, or several decisions to make.

If a small run hits a seam, a contract change, or more than one real decision, say so and switch to large. Carry the framing over and pick up at the large branch's step 2.

## Shape checklist

Both branches check these against the proposed shape and raise any that apply as decisions:

- **Ownership:** which module owns each cross-cutting concern (retries, config, logging, source of truth for shared data)
- **Config surface:** each new env var or flag, and why it can't be hardcoded or feature-flagged instead
- **Boundary failures:** what happens on bad input or a missing dependency at each seam
- **Not building:** what is deliberately deferred

## Small branch

### 1. Frame

Start from what the conversation already establishes — a diagnosis from an earlier debugging session, the ticket, the user's explanation — and read code only to fill the gaps.

- **A bug with no diagnosis yet:** read until you can name the root cause, then stop. Diagnosis explores the problem, never the fix.
- **Any other change:** read only the boundaries, as in the large branch's Frame.

**Done when** you can state the cause, or the existing pattern the change follows.

### 2. Propose the approach

Five lines or fewer:

- **Pitch**
- **Where** — the module that owns the change, and why there
- **Rejected** — the alternative and why, when one exists
- **Decide** — each open decision with your recommendation, including any the [shape checklist](#shape-checklist) raises

When only one path exists, the approach is the pitch plus where. If the user answers with an idea of their own, critique it on the same terms before defending yours.

**Done when** the user has agreed the approach and answered every decision.

### 3. Hand off

Restate the agreed pitch, then offer to make the change, or to write it up as a doc if the discussion grew. Then stop.

## Large branch

### 1. Frame

Read only what shows the terrain: the task or ticket, the project's agent docs, entry points, the existing seams and interfaces the work touches, and the data model. Leave implementation bodies unread. Restate the problem in two or three lines and list the domain vocabulary the shape will use.

**Done when** you can name every existing module and seam the work touches, and the user has not corrected the restatement.

### 2. Propose candidate shapes

Offer two or three genuinely different shapes, each ten lines or fewer: the modules, one line each on what they own, which way dependencies point, and the trade-off that separates this shape from the others. Close with your recommendation and why, then stop and wait. If the user answers with an idea of their own, critique it on the same terms before offering alternatives.

**Done when** the user has picked a shape, or a blend of them.

### 3. Settle the decisions

List the shape-level decisions the chosen shape still leaves open. Put two or three to the user per round, each with its options, the trade-off, and your recommended answer. Settled answers can open new decisions; keep going round until none is left. Include every decision the [shape checklist](#shape-checklist) raises.

Anything more detailed than the shape goes into open questions, with an owner.

**Done when** every shape-level decision is settled by the user or listed as an open question with an owner.

### 4. Write the shape doc

Give the pitch and a summary of the agreed shape in five lines or fewer, and ask whether it captures what you agreed. In the same message, suggest a path for the doc: follow wherever the project or user keeps working notes, or fall back to `<slug>-shape.md` at the project root. On a yes to both, write the doc to the confirmed path using [TEMPLATE.md](TEMPLATE.md).

**Done when** the file exists and every section of the template is filled in or deliberately left out.

### 5. Hand off

Suggest in one line what could come next: an implementation plan built from the shape doc, tickets, or a skeleton-first implementation (interfaces and wiring before bodies). Then stop.

## Revising an existing shape

If a shape doc already exists for this work, read it first and start from its open questions plus whatever prompted the revision. Update the pitch, components, responsibilities, and seams so they describe the shape as it stands now. Decisions are append-only: add the new decision with its date and mark the one it replaces as superseded, rather than rewriting it.

## For skills that come next

Downstream work treats what was agreed — the approach in chat, or the shape doc's **Decisions** section — as a scope lock: it may add detail, but changing a decision means reopening it with the user, here.
