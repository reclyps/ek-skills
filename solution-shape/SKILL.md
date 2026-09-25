---
name: solution-shape
description: Sketch the rough shape of a solution with the user — modules, responsibilities, seams, dependency direction, key decisions — before any implementation plan exists, and record it in a shape doc that later planning builds on. Use when the user invokes /solution-shape or asks to sketch or shape a solution. When the user is heading toward an implementation plan for non-trivial work and no shape has been agreed, offer it in one line, along the lines of "sounds like we're heading toward a plan — run /solution-shape to decide the shape together first?", and start only on a yes.
---

# Solution Shape

Agree the napkin sketch of a solution with the user before anyone writes a plan. This skill produces the shape and stops; planning, tickets, and code are other skills' jobs.

## Napkin resolution

Everything in this skill stays at napkin resolution: modules, one-line responsibilities, arrows, seams, trade-offs. File paths, method signatures, SQL, and edge-case handling belong to the plan — when one matters to the shape, record it as an open question and move on. If a turn starts filling with those, zoom back out.

The user makes the decisions. Claude proposes, recommends, and lays out trade-offs; a decision is settled only when the user has said so.

## Workflow

### 1. Frame

Read only what shows the terrain: the task or ticket, the project's agent docs, entry points, the existing seams and interfaces the work touches, and the data model. Leave implementation bodies unread.

Then restate the problem in two or three lines and list the domain vocabulary the shape will use.

**Done when** you can name every existing module and seam the work touches, and the user has not corrected the restatement.

### 2. Propose candidate shapes

Offer two or three genuinely different shapes, each ten lines or fewer: the modules, one line each on what they own, which way dependencies point, and the trade-off that separates this shape from the others. Close with your recommendation and why, then stop and wait.

If the user answers with an idea of their own, critique it on the same terms before offering alternatives.

**Done when** the user has picked a shape, or a blend of them.

### 3. Settle the decisions

List the shape-level decisions the chosen shape still leaves open. Put two or three to the user per round, each with its options, the trade-off, and your recommended answer. Settled answers can open new decisions; keep going round until no shape-level decision is left.

Always check the following, and raise any that apply:

- **Ownership:** which module owns each cross-cutting concern (retries, config, logging, source of truth for shared data)
- **Config surface:** each new env var or flag, and why it can't be hardcoded or feature-flagged instead
- **Boundary failures:** what happens on bad input or a missing dependency at each seam
- **Not building:** what is deliberately deferred

Anything more detailed than the shape goes into open questions, with an owner.

**Done when** every shape-level decision is settled by the user or listed as an open question with an owner.

### 4. Write the shape doc

Summarise the agreed shape in chat in five lines or fewer and ask whether it captures what you agreed. In the same message, suggest a path for the doc: follow wherever the project or user keeps working notes, or fall back to `<slug>-shape.md` at the project root. On a yes to both, write the doc to the confirmed path using [TEMPLATE.md](TEMPLATE.md).

**Done when** the file exists and every section of the template is filled in or deliberately left out.

### 5. Hand off

Suggest in one line what could come next: an implementation plan built from the shape doc, tickets, or a skeleton-first implementation (interfaces and wiring before bodies). Then stop.

## Revising an existing shape

If a shape doc already exists for this work, read it first and start from its open questions plus whatever prompted the revision. Update the components, responsibilities, and seams sections so they describe the shape as it stands now. Decisions are append-only: add the new decision with its date and mark the one it replaces as superseded, rather than rewriting it.

## For skills that come next

Downstream work treats the shape doc's **Decisions** section as a scope lock: a plan may add detail, but changing a decision means reopening it with the user, here.
