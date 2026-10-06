---
name: shape-doc
description: Write a solution shape doc from a shape that has already been agreed. The doc has a component diagram with each component's responsibilities, a sequence diagram of the main flow and its failure points, and the alternatives that were ruled out. Use when solution-shape hands over an agreed shape, or when the user asks to write up or diagram an agreed design. It does not make or reopen decisions; that is solution-shape's job.
---

# Shape doc

Turns an agreed shape into a doc a teammate can read cold: how the components relate, what each is responsible for, how a run moves through them, and what was ruled out. It records the shape, never how the shape was reached.

## Input

An agreed shape, from solution-shape or the user, covering:

- **Pitch:** one or two sentences on what changes and why
- **Components:** each one's module, whether it is new, changed, or existing, and its responsibility
- **Dependencies:** which component calls which, and what crosses each seam
- **Main flow:** the trigger and the steps of the path the change adds or alters, with what happens on failure at each step
- **Rejected alternatives:** each with why
- **Not building:** each with what would make it worth building
- **Open questions:** each with an owner

Check every part is present before writing. If one is missing, ask for it rather than reconstructing it from the conversation; a gap means that part isn't agreed.

## Write for a reader who wasn't there

The reader is a teammate or a planning agent who never saw the session. Leave out who proposed or agreed what and when, options that were later superseded, and any reference to the conversation, earlier drafts, or review rounds.

Keep rejected alternatives a reader might plausibly propose again, with their reasons; they can't be worked out from the shape. Leave out naming debates and options nobody would raise.

Stay at napkin resolution: components, responsibilities, seams. File paths, signatures, SQL, and edge-case handling belong to the plan; put any that matters to the shape under open questions.

**Where facts go.** Config, ownership, and non-structural decisions (what a user sees, a default) go in the bullet of the component they belong to. Failures and degraded results go in the sequence step where they happen.

## Diagrams

Mermaid. Set no custom fills (`fill:` in a `classDef` or `style`); they become unreadable in dark themes.

What the diagram rules mean by:

- **Module:** a unit of code ownership, such as a package, directory, or service.
- **Component:** a part of a module with one responsibility.
- **Actor:** a person or outside system that starts or receives the flow.

**Component diagram** (`flowchart LR`):

- One subgraph per module the change adds or alters, titled with its status, such as `thermal: new` or `battery: migrates onto shared`. A module with one component is a plain node, not a subgraph.
- Existing components the change only calls, and actors (`([name])`), sit outside any subgraph.
- Thick border for new or changed components, dashed for existing, using the template's `classDef`s. Datastores as cylinders: `[(name)]`.
- Arrows point from caller to dependency. Label only arrows that cross between modules, with what crosses.
- A changed module that uses seams already drawn is one node with one labeled arrow to the subgraph it depends on, such as `same three seams`.
- Aim for about a dozen nodes and fifteen arrows at most. Arrows tangle first; past that, the diagram has slipped to plan resolution.

**Sequence diagram:**

- Draw the flow a reader needs to understand the change: usually the runtime path from its trigger (a request, a scheduled run, an event). Draw the deploy flow only when deploying is the change.
- Participants are actors, or components from the component diagram under the same names.
- Draw each failure or degraded result that changes the outcome as an `alt` block at the step where it happens.
- If the change has no flow worth drawing, leave the section out and put failures with the responsibilities.

## Steps

1. **Path.** Use the path the caller gives. Otherwise suggest one, following wherever the project or user keeps working notes and falling back to `<slug>-shape.md` at the project root, and confirm it.
2. **Write.** Where the harness has subagents, hand the writing to one briefed with only this skill, [TEMPLATE.md](TEMPLATE.md), the agreed shape, and the path. It can't record session history it never saw. A mid-tier model is enough. Tell it to list any gap it still finds under open questions rather than fill it. Otherwise write it yourself under the rules above. If a doc already exists at the path, rewrite it in place to describe the shape as it stands now; an option the revision ruled out joins the alternatives, and nothing else of the old version is kept.
3. **Prose pass.** Run the prose-pass skill on the file, telling it the document is a shape doc and that headings, Mermaid blocks, and component names stay as written. Accept or reject its changes; the doc stays this skill's.
4. **Check.** Read the result against the input: every part present, nothing added, every template section filled in or deliberately left out. If a Mermaid renderer is available, render each diagram, fix parse errors, and simplify any diagram whose lines tangle: collapse modules, drop arrows the text already covers.
5. **Export.** Ask whether the diagrams should also be exported as SVGs, for Confluence or anywhere else that won't render Mermaid. On a yes, run `scripts/export-svg.sh <doc> [outdir]`. It writes a `.mmd` source and a white-background `.svg` per diagram, named after its section, into `<doc>-diagrams/` unless given another directory, using plain-text labels that Confluence can display.

## Chaining

When solution-shape calls this, return the doc's path, plus any SVG paths, and stop; the hand-off is solution-shape's. Run alone, report the same and stop.
