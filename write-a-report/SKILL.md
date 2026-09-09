---
name: write-a-report
description: Turn findings into a written report, memo, brief, or assessment for a human business audience — a manager, legal, a stakeholder — rather than for an agent to read back. Covers scoping audience and destination before drafting, tiering a short memo against a longer reference document, neutral framing, and a prose pass that strips the tics that make model-written prose painful to read. Use when the user asks for a report, memo, brief, executive summary, assessment, or findings write-up that someone else will read, or when existing research needs turning into something shareable through Confluence, email, or a doc. Not for Jira tickets (write-a-ticket), PRDs (write-a-prd), architecture decisions (adr), or for doing the research itself (research).
---

# Report Writer

Thoroughness is not the deliverable. A report that a busy reader abandons has failed, however
correct it is. Optimise for the reader acting on it.

## Establish two things before drafting

**Who reads it, and how much will they read?** A manager who wants three sentences and a decision is
a different brief from an engineer implementing the fix, and from counsel checking clause
references. If the user has not said, ask. Guessing produces a document that serves nobody.

**Where does it get published?** Confluence, email, a repo file and a Slack message have different
constraints. This decides whether internal file paths are usable, whether links are needed, and how
long is too long.

Both questions are cheap to ask and expensive to get wrong.

## Tier the output

One artefact rarely serves two audiences. Default to two, and say which is which:

- **A short memo.** One page. What the decision-maker reads. It must stand alone.
- **A reference document.** Every determination with its citation, for whoever implements or
  reviews. Length here is legitimate; this reader wants the evidence.

**Research notes are attachments, not pages.** Working files written for your own use during
investigation should be attached, not published. Ten pages of notes relabelled as deliverables is
how a report becomes unreadable. If a note genuinely needs reading, rewrite it for a reader.

## Framing

- **State the question before answering it.** A section headed "The answer" with no question stated
  reads as a non-sequitur.
- **Lead with what is established**, not with what was suspected. If an investigation was prompted
  by a concern, say what prompted it once and neutrally, then report findings.
- **Do not carry the investigating prompt's framing into the deliverable.** The brief that sent you
  looking may have assumed a conclusion. The report should not.
- **Name an owner for every open item.** "This cannot be determined" is a dead end; "ask X, who owns
  it" is an action. Prefer the second whenever a person could answer.
- **Headers and column labels must say what they mean.** "Covered?" is ambiguous; "Do the terms
  permit it?" is not.
- **Never refer to a section or column by position.** Name it. Column counts change; "the middle
  column" ages badly and confuses readers who count differently.
- **Every claim in the summary must be traceable to a section that supports it.** Summarising is
  where unsupported conclusions get introduced. Check each one against the body before shipping.

## Shape

There is no required structure. The shape follows the material.

Three things must be present somewhere regardless: the question, the conclusion near the top, and
who does what next. Beyond that, let the content decide.

One worked example, for a compliance assessment where the answer was "mostly not, and here is what
it would cost to fix": *question → answer → how serious it is → the open question we still need to
ask → what to do → caveat*. That fitted one report. A status update, a post-incident write-up, an
options comparison or a recommendation each want something different. Do not force material into a
shape it resists.

## Prose

Run the linter, then use judgement on what it flags:

```bash
scripts/check-prose.sh <file>
```

It counts the mechanical tells: em-dash density, consecutive bolded paragraph openers, a banned
phrase list, internal path references, positional references, and word count. All are signals, not
errors. See [PROSE.md](PROSE.md) for what each one indicates and the judgement calls the script
cannot make.

## Before handing over

- [ ] Audience and destination were established, not assumed
- [ ] The memo stands alone without the reference document
- [ ] The question is stated before the answer
- [ ] Every summary claim is supported by a section below it
- [ ] Every open item names who can resolve it
- [ ] No internal file paths, if the destination is external
- [ ] Linter run, and what it flagged is either fixed or a deliberate choice
- [ ] Column labels and headers are self-explanatory
