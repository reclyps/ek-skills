---
name: cupid-principles
description: The CUPID design properties (Composable, Unix philosophy, Predictable, Idiomatic, Domain-based) as design-time guidance. Use when designing or restructuring code that should follow CUPID, when drafting an implementation plan, PRD, or ticket under CUPID, when the user asks for CUPID-shaped work, or when another skill needs the CUPID vocabulary. For evaluating existing code, a PR, or a branch against CUPID with ratings, use cupid-review instead.
---

# CUPID Principles

Dan North's five properties of joyful code. They are *properties*, not rules — code is more or less CUPID, never compliant with it.

This is a reference to consult, not a session to run. Read what the task needs, apply it, carry on.

## The five properties

**C — Composable: plays well with others.** Small surface area, intention-revealing names, few dependencies. Design the interface so callers can combine, wrap, or replace the thing without knowing its insides.
→ *Could someone use this without reading its implementation?*

**U — Unix philosophy: does one thing well.** One reason to exist, describable in a sentence with no "and". Purpose set from the outside in, by what consumers need — not by internal tidiness. (Not SRP, which reasons inside-out.)
→ *Can I say what this does in one sentence, without "and"?*

**P — Predictable: does what you expect.** Behaviour obvious from structure and naming, deterministic, side effects explicit, errors surfaced rather than swallowed, observable, tested.
→ *Can a reader predict the behaviour before reading the body?*

**I — Idiomatic: feels natural.** Language idioms, framework idioms, and — the one that bites most — *local* idioms. Match the surrounding code's conventions over your own preference.
→ *Does this look like the code next to it?*

**D — Domain-based: models the problem.** Domain language in names and types, structure organised by domain rather than technical layer, types that encode domain constraints instead of primitives everywhere.
→ *Would a domain expert recognise the vocabulary?*

## Applying them while writing

Cheapest at the point of decision — naming a thing, fixing a module's boundary, sequencing a plan's steps — not as a pass afterwards.

- **Design pressure, not a scorecard.** A property already well served needs no action. Never manufacture an abstraction, a wrapper, or a type to satisfy a letter.
- **Stay inside the task.** Don't restructure surrounding code to serve a property the task didn't touch. Note it instead.
- **When they pull against each other, local idiom usually wins.** Consistency is what the next reader relies on; an abstractly better shape that matches nothing around it costs more than it returns. Flag the tension rather than resolving it silently.
- **Sequence matters for D.** Settle the domain vocabulary before naming modules — names chosen first are the ones that stick.

## In a plan, PRD, or ticket

When the deliverable is a plan rather than code, make the properties checkable by the reader:

- Name the domain vocabulary up front, and use those terms for the rest of the document (**D**).
- Give each new or changed module its one-sentence purpose (**U**).
- State each interface as what a caller must know — signature, invariants, error modes — not just the type (**C**).
- Say where the plan follows an existing local pattern, and call out any deliberate departure with its reason (**I**).
- Say how the behaviour will be verified, and which edge cases the tests pin down (**P**).

## Related

- **`codebase-design`** — canonical for module depth, seams, and where a boundary goes. CUPID's **C** and **U** cover the same ground from the outside; use codebase-design's vocabulary for the shape of a module, these properties for the broader read.
- **`cupid-review`** — evaluating existing code, a PR, or a branch against these properties with ratings and recommendations.

## Full rubric

[CUPID-PRINCIPLES.md](CUPID-PRINCIPLES.md) — per-property "what to look for" and anti-patterns, plus how the properties reinforce each other. Read it when judging code against the properties; the short form above is enough for most authoring.
