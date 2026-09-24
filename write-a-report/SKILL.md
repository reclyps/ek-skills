---
name: write-a-report
description: Produce the two-document deliverable for a large research question the user has been assigned — a one-page memo for a decision-maker plus a reference document citing every finding — with argument sign-off before drafting and fresh-context rewrite and fact-check passes. Use only when the user names this skill or explicitly asks for a memo with a backing document. Not for Confluence pages, status notes, comparison tables, ticket write-ups or other ordinary write-ups; write those directly. Not for tickets (write-a-ticket), PRDs (write-a-prd), ADRs (adr), or the research itself (research).
disable-model-invocation: true
---

# Report Writer

**When this applies.** Only for a large assigned research question where a memo plus a reference
document is the deliverable, or when the user named this skill. If it loaded any other way, write
the thing directly and mention `/write-a-report` in one line.

Thoroughness is not the deliverable. A report that a busy reader abandons has failed, however
correct it is. Optimise for the reader acting on it.

## 1. Establish audience and destination

**Who reads it, and how much will they read?** A manager who wants three sentences and a decision is
a different brief from an engineer implementing the fix, and from counsel checking clause
references. If the user has not said, ask. Guessing produces a document that serves nobody.

**Where does it get published?** Confluence, email, a repo file and a Slack message have different
constraints. This decides whether internal file paths are usable, whether links are needed, and how
long is too long.

Both questions are cheap to ask and expensive to get wrong.

## 2. Tier the output

One artefact rarely serves two audiences. Default to two, and say which is which:

- **A short memo.** One page. What the decision-maker reads. It must stand alone.
- **A reference document.** Every determination with its citation, for whoever implements or
  reviews. Length here is legitimate; this reader wants the evidence.

**Research notes are attachments, not pages.** Working files written for your own use during
investigation should be attached, not published. Ten pages of notes relabelled as deliverables is
how a report becomes unreadable. If a note needs reading, rewrite it for a reader.

## 3. Agree the argument

The last step before drafting. Show the user the argument and get their assent. Framing revisions are
cheap now and expensive once there is a draft, because a finished document anchors both of you to
the shape it already has.

Present this in the conversation, not as a file, in about 150 words:

- **The situation**, in one sentence: what the reader faces and why it matters now.
- **The conclusion**, in one or two. The actual claim, not "an assessment of X".
- **The spine.** The three to six steps that carry a reader from the situation to the conclusion,
  in order.
- **What you are leaving out**, and where it went. Most framing disagreements are about something
  omitted that the user would have kept, and this line surfaces them for free.
- **The stance**, where there is a genuine fork — leading with cost against leading with risk, a
  recommendation against a set of options.

This block checks the argument; it is not an outline, and none of its labels become headings.

Propose one framing. Name the alternative where a real fork exists, rather than offering a menu: a
menu hands the judgement back to the user, which is what this step exists to spare them. Use
`AskUserQuestion` for a discrete fork, plain text otherwise.

Then stop and wait. Do not draft until they answer.

## Framing rules

- **A reader who never saw the prompt must be able to tell what was asked and what the answer is,
  within the first few lines.** This is a test of content, not a required structure. The default
  rendering for a manager is an unlabelled opening paragraph: the situation, what makes it live now,
  then the answer. Consulting practice has done it this way since Minto, and the question is often
  never printed — the setup is written so the reader asks it and the next sentence answers it.
  Headings named "The question" and "The answer" are the native format of a legal memorandum, so use
  them when counsel is the reader and not otherwise.
- **Headings assert the finding; they do not label the slot.** "Retention exceeds the cap in three
  of four systems", not "The answer". This keeps the document scannable without a visible template,
  and it is what the reader of an executive summary expects.
- **Lead with what is established, not with what was suspected.** The brief that sent you looking
  may have assumed a conclusion; the report does not inherit it. Say what prompted the work once,
  neutrally, then report findings.
- **Name an owner for every open item.** "This cannot be determined" is a dead end; "ask X, who owns
  it" is an action. Prefer the second whenever a person could answer.
- **Column labels say what they mean.** "Covered?" is ambiguous; "Do the terms permit it?" is not.
- **Never refer to a section or column by position.** Name it. Column counts change; "the middle
  column" ages badly and confuses readers who count differently.
- **Every claim in the summary must be supported by a section below it.** Summarising is where
  unsupported conclusions get introduced. The QA pass checks this; write as though it will.

## Shape

There is no required structure. The shape follows the material.

Three things must reach the reader regardless: what was asked, the conclusion near the top, and who
does what next. How the first of those is rendered is settled under Framing rules, not here.
Beyond that, let the content decide.

One worked example, for a compliance assessment where the answer was "mostly not, and here is what
it would cost to fix": *question → answer → how serious it is → the open question we still need to
ask → what to do → caveat*. That is the order of the argument, not a list of headings; the first two
were a single opening paragraph. That fitted one report. A status update, a post-incident
write-up, an options comparison or a recommendation each want something different. Do not force material into a
shape it resists.

## Finishing passes

Three, in this order. None is optional, and the order matters where noted.

### 1. Prose rewrite, in a fresh context

A model editing its own draft defends its own phrasing: it reads its tics as intent, and the
structural ones are invisible from the inside. Hand the draft to a subagent that has not seen the
research, briefed with [REWRITE.md](REWRITE.md), on a mid-tier model. Where the harness has no
subagents, run it as a separate session or model call that sees only the brief and the draft.

### 2. The linter

```bash
scripts/check-prose.sh --max-words 1100 <memo>      # memo
scripts/check-prose.sh <reference-document>         # no ceiling
```

Six groups: mechanical, filler phrases, register (the ops and appraisal voice — landed, surfaced,
is real, load bearing), structure (antithesis, adverb openers, colon labels, punchline fragments,
triads, sentence cadence), positional references, and internal file paths.
[PROSE.md](PROSE.md) explains what each indicates.

The memo's real target is a single page a manager reads once and comes away with the gist and the
takeaway, which is a test of the document rather than a number. The 1100-word ceiling is a backstop
for when the page is clearly gone. Never cut or reword a working sentence to move the count — a long
memo has a section too many, so drop one or move it to the reference document.

**Flags default to fix.** Where a flag is a deliberate choice, keep it and name it in the handover
with the reason. Deciding silently that a flag was intentional is how the tics ship.

### 3. QA, in a fresh context

The last gate. A subagent briefed with [VERIFY.md](VERIFY.md) recomputes every number in Python,
tests every assertive sentence against the material below it, and reconciles the memo against the
reference document. Pass it both; a figure or a conclusion that differs between them is the failure
a reader notices first. A mid-tier model; the top tier when the deliverable is legal, compliance,
or financial. Where the harness has no subagents, use a separate session given only what VERIFY.md
says to pass.

**This runs after the rewrite, not before.** The rewriter's job is sharpening sentences, and a
sharper sentence usually makes a stronger claim, which is the failure this pass exists to catch.
REWRITE.md forbids strengthening a claim; running QA last is what enforces it.

**You apply the findings, not the verifier.** It has the evidence but not the framing the user
agreed, so it reports and you fix:

- A wrong figure gets corrected, and everything downstream of it rechecked. A corrected total moves
  the percentages that were derived from it.
- An overstated claim gets replaced by the weaker claim the evidence supports. Do not hedge it and
  do not delete it — the verifier hands you the true, smaller version to drop in.
- An unsupported claim either gains the evidence it needs in the body, or comes out.

Re-run the verifier if any number changed. Re-run the linter if the corrections touched more than a
sentence or two.

The user reads none of this. They get two or three lines in the handover: figures checked, errors
found and corrected, claims reworded.

## Before handing over

- [ ] Audience and destination were established, not assumed
- [ ] The argument was agreed with the user before drafting
- [ ] A reader who never saw the prompt learns the question and the answer in the first few lines
- [ ] The memo stands alone without the reference document
- [ ] Every open item names who can resolve it
- [ ] No internal file paths, if the destination is external
- [ ] Headings assert findings and are self-explanatory
- [ ] Rewrite pass done, and its result re-read for facts it flattened
- [ ] Linter run, its output pasted into the handover, every flag fixed or named
- [ ] QA pass clean, or the outstanding items named in the handover
