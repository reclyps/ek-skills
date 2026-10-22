---
name: write-a-ticket
description: Write ticket content — title, description, requirements — to a markdown file. Tracker-agnostic and file-only; it never calls a tracker API and never creates anything. Use when the user wants the write-up itself, such as "write a ticket/task/story/epic", "draft a ticket", or "turn this into a ticket", or when they want to review the wording before anything is filed. Writes outcome-first requirements that keep only the specifics a reader needs (what to find, what will bite, what blocks it, what is already decided), grounded in the codebase or in operational reality. Not for filing — creating the issue in Jira is the jira-task / jira-epic skills.
---

# Ticket Writer

Write tickets that are tight and scannable: outcome-first, specific only where it counts. A reader should grasp the task from the top-level bullets alone, and reach for detail only when they want it. Length is not a proxy for quality.

## Output format

Every task includes these sections in order, separated by blank lines:

```md
# <Title>

**Description**

<Narrative-prose paragraph: background, motivation, what the work achieves. See step 3.>

**Requirements**

<Top-level bullets, each one concrete requirement. Detail lives in sub-bullets. See step 3.>
```

Add a context block (a table, diagram, or reference list) between Description and Requirements only when it saves the reader real work. Add no other sections (out of scope, notes, open questions) unless the user asks, or supplies design guidance that spans requirements (see Design guidance).

## What goes in

Requirements state outcomes: what is true when the work is done, in terms someone can verify. The how is the developer's call. Keep a specific only when it is one of these:

| Kind | Keep it when | Example |
|---|---|---|
| Locator | The work acts on named things: env vars, resources, flags, routes, or a file that is itself the target. Without the names, the reader redoes the investigation. | "`LEGACY_BILLING_KEY` and `SIGNUP_CONTACT` are removed from every App Service, with their Key Vault secrets" |
| Gotcha | A trap that causes breakage, rework, or the wrong fix. Give the one-clause why. | "Delete the mailer module rather than wiring it up; it reads two settings unset on every slot, so it has never worked" |
| Dependency | A blocker or an ordering constraint. | "Start after EN-1234 merges; it rewrites the same routes" |
| Settled decision | A constraint already decided that the reader shouldn't reopen. State it as fact, never as the question that settled it. | "Soft-deleted vaults are retained 90 days" |

Drop the rest: utilities, params, step order, commands, and any pattern pointer beyond the one Shape allows. A competent developer finds or decides those. The exception is design guidance the user supplies.

Every specific you keep must:

- **Stand alone.** If the reader would need this session to parse it, add the one-clause why or cut it.
- **Be verified.** An inference you couldn't confirm becomes a requirement to confirm it, naming who can ("Confirm with the release owner that release doesn't read from the `-alt` server").
- **Be true when filed.** Check it against what already happened in the session: resources deleted, PRs merged, decisions changed.

**Shape.** When a code ticket adds a module or reshapes one, state the intended shape in one or two sub-bullets under the requirement that introduces it:

- Purpose and boundary, set from the outside in: what callers need the module to do, in one sentence, and what it leaves to existing code (transport, persistence, formatting). "Notification logic lives in its own module whose one job is deciding who to notify; sending goes through the existing email client."
- The local pattern to match, if one exists, with its reason. "Mirror the battery report flow's structure, so the two can be maintained together."

Write shape in plain language, framed by what the module does for its callers: "does one thing well", "fits the code around it", "named in the problem's terms". Avoid inside-out rule names such as single responsibility; they invite rigid decomposition rather than a purpose set by consumers. Leave out CUPID and the names of review skills, since the team doesn't use them. Function names, signatures, and file layout stay out. Skip shape for renames, deletions, config, and infra work, and never invent an abstraction to have something to say. The reasoning comes from the `cupid-principles` skill and the readability rules: borrow the reasoning, not the vocabulary.

Infra and ops specifics go stale fastest. Keep the resource names; drop the portal steps and exact commands.

A user who writes `--high-level` or "high-level mode" is asking for the default.

## Design guidance

Not by default. When the user supplies design guidance in the prompt (an approach, a module or pattern to follow, an interface shape, a pitfall from experience) or asks for implementation detail, include it. This is typical when the ticket is for a less experienced developer.

- Put it in sub-bullets under the requirement it shapes. When it spans several requirements, add a short **Design guidance** block after Requirements.
- Carry the user's guidance; don't extend it. Ground what they name: resolve "follow the battery email flow" to the actual module, and if it doesn't do what they described, say so in chat. Beyond the shape lines, don't add guidance of your own.
- Write it as guidance with its reason ("Follow X, because Y"), not a script, so the developer can deviate knowingly.
- A design agreed earlier in the session is not guidance by default. Its decisions go in as settled decisions; its how stays out unless the user asks to carry it over.

## Workflow

### 1. Assess whether you have enough context

If the prompt clearly describes what the task is, why it matters, and roughly what it involves, write it directly.

If the prompt is vague or missing key context (no "why", unclear scope, ambiguous approach), ask focused clarifying questions first — only what you need to produce a good task.

A detailed plan or a prior investigation in this session can satisfy this step (and shapes how much of step 2 you need).

### 2. Ground the specifics

Ground to find and verify the specifics in What goes in, not to work out how to build the thing.

- Take stock of what you already hold: the prompt, a referenced plan, a prior investigation. Mine it for locators, gotchas, dependencies, and decisions; leave its steps behind. Don't re-explore to rediscover what you have.
- Verify the few specifics the ticket depends on, especially from a plan by another author or an older session that may be stale. Don't sweep. For shape, confirm the local pattern you point to exists and works the way you describe it.
- With no grounding at all, explore enough to find them.

Where grounding comes from depends on the work:

- **Code changes:** the codebase.
- **Infra, ops, process, config:** operational reality: live resource state, a prior investigation, IaC or config, an existing runbook or process. Reuse a prior investigation rather than re-running it. It's fine for an anchor to be an open question ("where the IaC lives"); name it as such instead of inventing detail. Don't manufacture code specifics (file paths, params) that don't apply.

### 3. Write the task

**Title**: Short, action-oriented (e.g. "Add Pagination to Search Results API").

**Description**: Write for a mixed product-and-engineering audience as flowing narrative prose. Lead with the impact (what goes wrong today, or what the work enables), then the cause. Default to a single paragraph (3-6 sentences, scaling with complexity). No implementation details here — those belong in requirements.

When the task is part of a larger initiative (an epic or multi-ticket batch), situate it: what the initiative is, what this task enables, so a reader who hasn't seen sibling tickets can follow. Refer to related work by name, Jira link, or natural sequence ("the App Configuration provisioning work") rather than mechanical framing ("this ticket replaces the prior ticket's stand-in").

**Requirements**: Typically 4-8 top-level bullets. Structure them so the task reads top-down:

- Each top-level bullet is one outcome, stated in a line or two. It reads cleanly on its own — a reader who stops at the top level understands the scope.
- Sub-bullets carry the specifics from What goes in (shape included), plus any design guidance the user supplied. Add one only when it carries real signal, never to restate the parent.
- Leave the developer room to explore and decide. Prefer one strong pointer over an exhaustive list.

Don't inflate: don't restate the description, don't spell out what a competent developer would find on their own, and don't nest for the sake of nesting.

**Style**: Assume the reader has only the ticket: state a fact inline rather than citing a document they may not have. Shared repository paths are fine; runbooks, investigation notes and local working files are not. Em dashes and stray internal paths are the prose pass's job in step 5, not something to hand-police here.

### 4. Ask where to save

Ask where to save the file. Default to a markdown file with a `task-` prefix and a slug from the title (e.g. `task-add-pagination-to-search-results.md`), but respect a naming preference if given.

### 5. Prose pass

The file exists now, so run the prose pass over it.

1. `scripts/check-prose.sh <file>` — see [PROSE.md](PROSE.md) for what each flag indicates. Flags
   default to fix; keep one only deliberately, and say which and why.
2. Hand the file to a subagent (or a separate session, where the harness has none) briefed with
   [REWRITE.md](REWRITE.md), on a mid-tier model, telling it the document is a Jira ticket
   description so it preserves the format. Then run the linter again on the result.

Most of this file is not prose. Weigh the cadence, triad and punchline flags against the
Description only, and ignore them where they land on Requirements bullets or a context table — those
are meant to be clipped.

The `prose-pass` skill is the same machinery if you want it on its own.

## Multiple tasks

If the user asks for multiple tasks in one invocation, produce each as a separate file by default. Confirm the save location once, not per file.

If the user asks for multiple tasks in a single file, combine them with `---` horizontal rules between tasks. Each keeps its own `# Title`, Description, and Requirements.

When the tasks belong to the same epic, apply the situate-in-context guidance from step 3 to each, since readers won't see the file-level intro once tickets are imported individually.

## Epics

If the user requests an epic, produce a title and description only (no requirements), one or two paragraphs. Write it for the product owner: the impact first, the mechanism briefly after. Specifics belong in the child tasks.

## Audience override

The default audience is a mix of product and engineering. If the user specifies another (e.g. "for a junior dev", "for leadership"), adjust tone and how much you explain. An audience override doesn't add how-to beyond shape; that comes only from design guidance the user supplies.
