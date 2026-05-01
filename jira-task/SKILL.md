---
name: jira-task
description: Write Jira task descriptions as structured markdown files. Explores the codebase for context when the task involves code changes. Use when user asks to write a task, create a ticket, draft a Jira story, or needs a task write-up for their board.
---

# Jira Task Writer

## Output format

Every task must include these sections in order. Separate each section with a blank line for readability:

```md
# <Title>

**Description**

<Default to a single paragraph (typically 3-6 sentences, scaling to complexity). Write as flowing narrative prose. Explain the background, why this work is needed, and what it achieves. The audience is a mix of product and engineering reading this on a Jira board — pitch to the lower-context reader so the description stays high-level. It should also orient cold readers who haven't seen sibling tickets when this task is part of a larger initiative.>

<Optional additional context — tables, diagrams, references, or supplementary detail — when it helps the reader understand the task. Include when the user provides it or when the task benefits from it, but do not add filler.>

**Requirements**

<Bullet point list of requirements>
```

## Workflow

### 1. Assess whether you have enough context

If the user's prompt clearly describes what the task is, why it matters, and roughly what it involves — write the task directly.

If the prompt is vague or missing key context (e.g. no "why", unclear scope, ambiguous technical approach), ask focused clarifying questions before writing. Ask only what you need to produce a good task — no more.

### 2. Explore the codebase (when the task involves code changes)

Before writing requirements, explore the codebase to ground the task in reality. Look for:

- Existing patterns and conventions the task should follow
- Specific files, modules, or utilities relevant to the work
- Constraints or gotchas a developer could trip over (e.g. runtime limitations, backward compatibility concerns, shared code whose behaviour must be preserved)

### 3. Write the task

**Title**: Short, action-oriented (e.g. "Add Pagination to Search Results API").

**Description**: Write for a mixed audience of product and engineering as flowing narrative prose. Explain the problem, the motivation, and what the task achieves at a high level. Default to a single paragraph. Do not include implementation details here — save those for requirements.

When the task is part of a larger initiative — an epic, a multi-ticket batch — situate it in that context (what the initiative is, what this task enables) so a reader who hasn't seen sibling tickets can still follow. Refer to related work by name, with a Jira link, or by natural sequence ("the App Configuration provisioning work", "in the previous task to provision X") rather than mechanical procedural framing ("this ticket replaces the prior ticket's stand-in").

**Requirements**: Typically 4-8 bullets, but use as many as the task demands. Use nested bullets when a requirement needs clarification, sub-steps, or examples — but don't nest for the sake of it. Each top-level bullet should be a concrete, verifiable requirement. Include:

- What needs to happen, stated clearly enough that completion is unambiguous
- For code tasks: relevant codebase context and hints (existing patterns to follow, specific files or utilities to use) — but leave room for the developer to explore and make their own decisions
- Constraints, gotchas, or acceptance criteria relevant to the task domain

### 4. Ask where to save

Ask the user where to save the file. Default to a markdown file with a `task-` prefix and a slug derived from the title (e.g. `task-add-pagination-to-search-results.md`), but respect the user's naming preference if they specify one.

## Multiple tasks

If the user asks for multiple tasks in one invocation, produce each as a separate file by default. Confirm the save location once (not per file).

If the user asks for multiple tasks in a single file, combine them into one file using `---` horizontal rules to separate each task. Each task keeps its own `# Title`, Description, and Requirements sections.

When the multiple tasks belong to the same epic or initiative, apply the situate-in-context guidance from step 3 to each task — readers won't see the file-level intro once tickets are imported individually.

## Epics

If the user requests an epic, produce a title and description only — no requirements section — and keep the description to one or two paragraphs.

## Audience override

The default audience is a mix of product and engineering. If the user specifies a different audience (e.g. "write this for a junior dev" or "this is for leadership"), adjust the tone and detail level accordingly.