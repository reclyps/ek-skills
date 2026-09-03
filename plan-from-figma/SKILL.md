---
name: plan-from-figma
description: Produce a structured implementation plan markdown file from a Figma design link, after verifying the Figma MCP works, discovering the project's conventions, inventorying available primitives, and asking focused clarifying questions before drafting. Use when the user provides a Figma URL and wants a plan rather than code — phrases like "plan this Figma", "write an implementation plan from this design", "how would we build this", "spec out this design". Do not use for direct Figma-to-code (use figma-implement-design) or for writing a PRD (use write-a-prd).
---

# Plan from Figma

## Quick start

Run this when the user gives you a Figma URL and asks for a plan (not code). Output is a single markdown file the user can review, hand off, or feed into downstream skills like `/to-issues` and `/write-a-ticket`.

## Workflow

All five steps below are load-bearing. Skipping any of them tends to produce shallow or wrong plans.

### 1. Verify the Figma MCP works

Before parallelizing any other work, make one minimal Figma MCP call (e.g. `get_metadata` against the design node from the user's URL). If it fails — especially with session-expired or auth errors — surface the error to the user and stop. Don't loop on retries; don't fall back to a codebase-only plan — the value of this skill is grounded in the design.

### 2. Discover the project's conventions

Locate and read the project's agent-instruction files: `CLAUDE.md`, `AGENTS.md`, `AGENTS_README.md`, or `README.md`, at the repo root and in obvious subdirectories. Follow their pointers to convention documents (frontend/styling, architecture, logging, testing) and any module-specific docs whose topic matches the feature.

If the project documents reusable UI primitives or design tokens, plan to reuse them rather than propose new ones. If no agent docs exist, note the gap in the plan's Open questions section and lean more heavily on clarifying questions in step 4.

### 3. Inventory the full design, then explore in parallel

A design almost always has **many sibling top-level frames** — one per screen, state, or flow. Planning from "the top frame" alone produces a partial view and a wrong plan. Steps 3a and 3b exist to guarantee total coverage; do them in order.

#### 3a. Build the top-level frame catalog (coverage gate)

Call `get_metadata` on the **page / canvas node** from the user's URL — metadata is structure-only (ids, names, types, geometry) and far lighter than design context. Extract **every direct-child frame** into a catalog table: `node id | frame name`.

**If the response is too large to hold in context, it gets saved to disk. Read that file back and `grep`/script out the depth-1 frame nodes — never proceed on the unparsed blob.** A large response means many frames, the exact case where missing one matters most.

This catalog is the master checklist for the rest of the skill. Nothing gets dropped silently.

#### 3b. Explore every frame and the codebase in parallel

**Figma side:** fan out **one `Explore` subagent per top-level frame** (batch small/related frames together if there are many). Each subagent fetches that frame's design context and screenshot, reads any embedded notes or annotation frames (they often hold hard requirements not visible in the render), and returns a **compact structured summary**: purpose, key components, states/variants, annotations, and which shared primitives it implies. The orchestrator collects summaries — not raw payloads — keeping its context lean and scaling to large designs.

**Codebase side (in parallel):** identify where the feature should live and inventory the shared primitives that match the design's components (cards, buttons, forms, theme/colors, hooks, API caller patterns, repo patterns, route handlers, DB schema conventions).

Use the `Explore` subagent for open-ended searches; use direct Read for known paths. Run independent searches in parallel.

#### Coverage rule (do not skip)

Before moving on, confirm **every catalog entry from 3a has a 3b summary**. If any frame is still unexplored, finish it now. Scope — what's in vs deferred — gets decided with the user in step 4, but that decision must come from a complete picture, not a partial one.

### 4. Ask focused clarifying questions before drafting

Ask as many questions as the plan genuinely needs. Don't pad, don't truncate. `AskUserQuestion` supports 1–4 questions per call, so run multiple rounds if needed.

Common areas to surface:

- **Screen scope** — present the full top-level frame catalog from step 3a ("the design has N top-level frames: …") and confirm which are in scope vs deferred. This is the single most important question when the design spans multiple screens.
- **Scope** — UI-only vs full stack, what's in vs out
- **Naming conflicts** with existing code
- **Restructuring** of adjacent nav, routes, or files the new work touches
- **External systems** referenced in Figma notes (admin dashboards, queues, etc.) — do they exist already, are they planned, or are they hypothetical
- **Anything the design left undecided**

Skip a question if the user's original prompt already answered it. If no Figma URL was provided, ask for one here. If the user gave overriding context (e.g. "UI-only", "this lives in the X module", "skip Y"), apply it directly and skip the corresponding question.

### 5. Draft the plan

Ask the user where to save. Default filename: a slugified version of the design/page name (or the primary in-scope frame) in a directory of the user's choice.

**Required sections (every plan):**

- Scope summary
- Build order (numbered list)
- Open questions / follow-ups (bulleted; bold prefix per item)

**Optional sections — include only those that apply:**

- Nav / routing changes
- UI components
- Domain layer (services, repos, types)
- API routes
- DB schema
- Tests + stories

**Format conventions:**

- Tables for "files to edit / files to create" with two columns: path, change
- Numbered list for build order
- Bulleted list with bolded prefixes for open questions
- Capture decisions made during clarifying questions in a "Decisions captured" trailer so future readers see how scope was nailed down

**Coverage check:** every frame in the step 3a catalog must appear in the plan — either in the build order or in an explicit deferred / out-of-scope list. None left unaccounted for.

Before delivering, scan the draft once for: any catalog frame missing from both build order and the deferred list, missing decisions in the trailer, paths or component names too vague to chain into tickets, open questions that the work actually resolved (move them out), and unfilled placeholders.

The plan is meant to feed downstream skills like `/to-issues` and `/write-a-ticket`. Keep file paths, component names, and architectural decisions specific enough to survive being broken into separate tickets.

## Chaining and explicit invocation

Explicit invocation always overrides this skill's contextual triggers. If the user chains this skill with `/write-a-ticket`, `/to-issues`, `/figma-implement-design`, or anything else, follow the chain — don't refuse, redirect, or insert steps they didn't ask for.
