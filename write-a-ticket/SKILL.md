---
name: write-a-ticket
description: Write ticket content — title, description, requirements — as a structured markdown file. Tracker-agnostic and file-only: never calls a tracker API. Grounds the write-up in the codebase for code changes, or in operational reality (live state, prior investigation, IaC) for infra/ops/process work. Use when the user asks for a ticket, task, story, or epic write-up. To create the ticket in Jira, use the jira-task skill instead.
---

# Ticket Writer

Write tasks that are tight and scannable. Length is not a proxy for quality: a reader should grasp the task from the top-level bullets alone, and reach for detail only when they want it.

## Output format

Every task includes these sections in order, separated by blank lines:

```md
# <Title>

**Description**

<Narrative-prose paragraph: background, motivation, what the work achieves. See step 3.>

**Requirements**

<Top-level bullets, each one concrete requirement. Detail lives in sub-bullets. See step 3.>
```

Add a context block (a table, diagram, or reference list) between Description and Requirements only when it saves the reader real work. Omit it if it would be filler.

## Detail level

Two modes. The default is grounded-but-tight. The high-level mode trades specifics for durability.

| | Default | High-level |
|---|---|---|
| Requirements state | What to build, grounded in the codebase or operational reality | The outcome / acceptance criteria |
| Implementation specifics (files, utilities, params) | In sub-bullets, when they carry signal | Omitted |
| Grounding (step 2) | Yes | Skip or keep light |
| Use when | Approach is settled | Specifics may still change |

Enter high-level mode when the user passes `--high-level` (or `--abstract`), or asks for it in words ("keep this high-level", "write it abstract", "the details aren't settled yet"). Otherwise use the default.

## Workflow

### 1. Assess whether you have enough context

If the prompt clearly describes what the task is, why it matters, and roughly what it involves, write it directly.

If the prompt is vague or missing key context (no "why", unclear scope, ambiguous approach), ask focused clarifying questions first — only what you need to produce a good task.

A detailed plan or a prior investigation in this session can satisfy this step (and shapes how much of step 2 you need).

### 2. Ground the task (default mode)

Requirements must be grounded in reality, not invented. Where that grounding comes from depends on the work.

**Code changes (the common case) — ground in the codebase.** Take stock of the grounding you already hold before exploring:

- If the prompt or a referenced plan already supplies verified specifics (paths, conventions, constraints, gotchas), use them. Don't re-explore to rediscover what you already have.
- Explore only to fill genuine gaps, or to spot-check claims you have reason to doubt (e.g. a plan from another author or an older session that may be stale). Verify a few load-bearing references rather than sweeping.
- With no grounding at all, explore enough to find the relevant patterns, files, and constraints before writing.

What to look for when you do explore:

- Existing patterns and conventions the task should follow
- Specific files, modules, or utilities relevant to the work
- Constraints or gotchas a developer could trip over (runtime limits, backward-compat, shared code whose behaviour must be preserved)

**Non-code work (infra, ops, process, config) — ground in operational reality, not a codebase sweep.** The anchor is what's actually deployed or done: live resource state, a prior investigation in this session, IaC/config, or an existing runbook or process. Reuse a prior investigation rather than re-running it. It's fine for the concrete anchor to be an open question (e.g. "where the IaC lives") rather than a file you can open — name it as such instead of inventing detail. Don't manufacture code specifics (file paths, params) that don't apply.

In high-level mode, skip this step or keep it light. Deep grounding is wasted when the specifics may change, and it drags soon-stale detail into the ticket. This applies to grounding you already hold as much as to grounding you would go and gather: a prior investigation or planning session is context for choosing the requirements, not material to put in them.

### 3. Write the task

**Title**: Short, action-oriented (e.g. "Add Pagination to Search Results API").

**Description**: Write for a mixed product-and-engineering audience as flowing narrative prose. Explain the problem, the motivation, and what the task achieves at a high level. Default to a single paragraph (3-6 sentences, scaling with complexity). No implementation details here — those belong in requirements.

When the task is part of a larger initiative (an epic or multi-ticket batch), situate it: what the initiative is, what this task enables, so a reader who hasn't seen sibling tickets can follow. Refer to related work by name, Jira link, or natural sequence ("the App Configuration provisioning work") rather than mechanical framing ("this ticket replaces the prior ticket's stand-in").

**Requirements**: Typically 4-8 top-level bullets. Structure them so the task reads top-down:

- Each top-level bullet is one concrete, verifiable requirement, stated in a line or two. It reads cleanly on its own — a reader who stops at the top level understands the scope.
- Put specificity in sub-bullets: clarifications, examples, param details, edge cases, and (default mode) implementation hints such as patterns to follow or specific files and utilities to use. For non-code tasks that specificity is operational (the command to run, the resource or process affected, the verification step), not file paths. Add a sub-bullet only when it carries real signal, never to restate the parent.
- Leave the developer room to explore and decide. Prefer one strong pointer over an exhaustive list.

Don't inflate: don't restate the description, don't spell out what a competent developer would find on their own, and don't nest for the sake of nesting.

In high-level mode, requirements state outcomes and acceptance criteria, not the how. Drop file paths, utility names, and step-level detail; keep sub-bullets only where they sharpen the outcome. Same requirement, both modes:

- Default: a short top-level bullet ("Add cursor-based pagination to the search endpoint") with sub-bullets for the params, the pagination pattern to follow, and the opaque-cursor constraint.
- High-level: one bullet stating the outcome ("Search results can be paginated: clients request a bounded page size and page through all results in order"), no file or param specifics.

**Style**: Avoid em dashes where possible; prefer commas, parentheses, or sentence breaks. Assume the reader has only the ticket: state a fact inline rather than citing a document they may not have. Shared repository paths are fine, runbooks and investigation notes and local working files are not.

### 4. Ask where to save

Ask where to save the file. Default to a markdown file with a `task-` prefix and a slug from the title (e.g. `task-add-pagination-to-search-results.md`), but respect a naming preference if given.

## Multiple tasks

If the user asks for multiple tasks in one invocation, produce each as a separate file by default. Confirm the save location once, not per file.

If the user asks for multiple tasks in a single file, combine them with `---` horizontal rules between tasks. Each keeps its own `# Title`, Description, and Requirements.

When the tasks belong to the same epic, apply the situate-in-context guidance from step 3 to each, since readers won't see the file-level intro once tickets are imported individually.

## Epics

If the user requests an epic, produce a title and description only (no requirements), one or two paragraphs.

## Audience override

The default audience is a mix of product and engineering. If the user specifies another (e.g. "for a junior dev", "for leadership"), adjust tone and detail accordingly. This is independent of the detail-level mode.
