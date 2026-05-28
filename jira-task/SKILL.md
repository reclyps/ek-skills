---
name: jira-task
description: Write Jira task descriptions as structured markdown files. Grounds tasks in the codebase when the work involves code changes. Use when user asks to write a task, create a ticket, draft a Jira story, or needs a task write-up for their board.
---

# Jira Task Writer

## Output format

Every task must include these sections in order. Separate each section with a blank line for readability:

```md
# <Title>

**Description**

<Narrative-prose paragraph: background, motivation, and what the work achieves. See step 3 for full guidance.>

<Optional additional context (tables, diagrams, references) when it helps the reader. Omit if it would be filler.>

**Requirements**

<Bullet point list of requirements>
```

## Workflow

### 1. Assess whether you have enough context

If the user's prompt clearly describes what the task is, why it matters, and roughly what it involves, write the task directly.

If the prompt is vague or missing key context (e.g. no "why", unclear scope, ambiguous technical approach), ask focused clarifying questions before writing. Ask only what you need to produce a good task and nothing more.

A detailed plan or a prior investigation in this session can satisfy this step (and shapes how much of step 2 you need).

### 2. Ground the task in the codebase (when the task involves code changes)

Requirements must be grounded in the real codebase, not invented. Before writing them, take stock of the grounding you already hold:

- If the prompt or a referenced plan already supplies verified specifics (file paths, conventions, constraints, gotchas), use them. Do not re-explore to rediscover what you already have, since that wastes effort and risks drifting from the plan.
- Explore only to fill genuine gaps, or to spot-check claims you have reason to doubt (e.g. when the plan came from another author or an older session and may be stale). Verify a few load-bearing references rather than sweeping.
- If you have no grounding at all, explore enough to find the relevant patterns, files, and constraints before writing.

The goal is grounded requirements, not a fixed exploration pass. What to look for when you do explore:

- Existing patterns and conventions the task should follow
- Specific files, modules, or utilities relevant to the work
- Constraints or gotchas a developer could trip over (e.g. runtime limitations, backward compatibility concerns, shared code whose behaviour must be preserved)

### 3. Write the task

**Title**: Short, action-oriented (e.g. "Add Pagination to Search Results API").

**Description**: Write for a mixed audience of product and engineering as flowing narrative prose. Explain the problem, the motivation, and what the task achieves at a high level. Default to a single paragraph (typically 3-6 sentences, scaling with complexity). Do not include implementation details here; save those for requirements.

When the task is part of a larger initiative such as an epic or multi-ticket batch, situate it in that context (what the initiative is, what this task enables) so a reader who hasn't seen sibling tickets can still follow. Refer to related work by name, with a Jira link, or by natural sequence ("the App Configuration provisioning work", "in the previous task to provision X") rather than mechanical procedural framing ("this ticket replaces the prior ticket's stand-in").

**Requirements**: Typically 4-8 bullets, but use as many as the task demands. Use nested bullets when a requirement needs clarification, sub-steps, or examples, but don't nest for the sake of it. Each top-level bullet should be a concrete, verifiable requirement. Include:

- What needs to happen, stated clearly enough that completion is unambiguous
- For code tasks: relevant codebase context and hints (existing patterns to follow, specific files or utilities to use), but leave room for the developer to explore and make their own decisions
- Constraints, gotchas, or acceptance criteria relevant to the task domain

**Style**: Avoid em dashes where possible; prefer commas, parentheses, or sentence breaks.

### 4. Ask where to save

Ask the user where to save the file. Default to a markdown file with a `task-` prefix and a slug derived from the title (e.g. `task-add-pagination-to-search-results.md`), but respect the user's naming preference if they specify one.

## Multiple tasks

If the user asks for multiple tasks in one invocation, produce each as a separate file by default. Confirm the save location once (not per file).

If the user asks for multiple tasks in a single file, combine them into one file using `---` horizontal rules to separate each task. Each task keeps its own `# Title`, Description, and Requirements sections.

When the multiple tasks belong to the same epic or initiative, apply the situate-in-context guidance from step 3 to each task, since readers won't see the file-level intro once tickets are imported individually.

## Epics

If the user requests an epic, produce a title and description only (no requirements section) and keep the description to one or two paragraphs.

## Audience override

The default audience is a mix of product and engineering. If the user specifies a different audience (e.g. "write this for a junior dev" or "this is for leadership"), adjust the tone and detail level accordingly.
