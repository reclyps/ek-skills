---
name: prose-pass
description: Strip model-written tics from a finished document — a linter pass over the mechanical and structural tells, then a rewrite by a subagent that has not seen the research. Use when the user asks to run the prose pass, check the prose, tighten or de-model a written file, or when another skill hands over a draft for cleaning. Operates on a file that already exists; it does not write, research, or fact-check the document.
---

# Prose pass

Two passes over a document a person will read. Works on anything — a report, a ticket description,
an ADR, an email — and preserves the conventions of whatever it is handed.

It does not check whether the document is *true*. Arithmetic and claim support are a separate job;
`write-a-report` carries a QA brief for that.

## Inputs

A file path. Optionally a document type, which the rewriter uses to know what format to preserve,
and a word ceiling if the caller has a real one.

If the user names no file and the conversation just produced one, use that. If neither, ask.

## 1. Linter

```bash
scripts/check-prose.sh [--max-words N] <file>
```

Six groups: mechanical, filler phrases, register (the ops and appraisal voice — landed, surfaced,
is real, load bearing), structure (antithesis, adverb openers, colon labels, punchline fragments,
triads, sentence cadence), positional references, and internal file paths. [PROSE.md](PROSE.md)
explains what each indicates.

Length is reported, never scored. Pass `--max-words` only when the caller has a genuine ceiling.

**Flags default to fix.** Where one is a deliberate choice, keep it and say which and why.

## 2. Rewrite, in a fresh context

A model editing its own draft defends its own phrasing: it reads its tics as intent, and the
structural ones are invisible from the inside. Hand the file to a subagent briefed with
[REWRITE.md](REWRITE.md), which carries the hard limits — never strengthen a claim, never add a
fact, never touch a number or a qualifier, no restructuring. Pin it to Sonnet.

Then run the linter again on the result, and read the result yourself. A rewriter working without
context will occasionally flatten a qualifier that mattered.

## Chaining

When another skill calls this, it owns the document and this skill owns the prose. Return to the
caller:

- the linter output after the rewrite
- what the rewriter changed, in its own words
- anything still flagged, with the reason it was kept

The caller decides whether to accept the rewrite. Never publish, file, or commit the document —
that belongs to whoever called.

## Running it alone

Report the same three things to the user, then stop. Do not offer to keep editing.
