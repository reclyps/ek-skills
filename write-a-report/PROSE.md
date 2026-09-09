# Prose tells and what they indicate

The linter counts the mechanical ones. This file explains what each signal means and covers the
judgement calls a script cannot make.

None of these is a rule to obey mechanically. Each is a habit that, in aggregate, makes prose feel
machine-written and tiring. One em-dash is fine; forty in a document is a tell.

## What the linter flags

**Em-dash density.** The single strongest tell. Reach for a comma, a colon, or a full stop first.
Above roughly one per 200 words, the prose starts to feel breathless. A document with 114 of them
was described by its reader as painful.

**Consecutive bolded paragraph openers.** Starting every paragraph with a bolded thesis makes the
reader feel shouted at, and it flattens emphasis so nothing stands out. Use headings for structure
instead. Two or three across a long document is fine; one per paragraph is not.

**Banned phrases.** Each is filler that adds no information:

| Phrase | Why it goes |
| --- | --- |
| "worth noting", "worth recording", "worth stating" | If it were not worth saying, it would not be in the document. Say the thing. |
| "It is worth" anything | Same. |
| "load-bearing" | Jargon dressed as insight. |
| "genuinely", "materially", "meaningfully" | Intensifiers that let a weak claim pass as a strong one. |
| "That said", "Note that" | Filler transitions. |
| "the cheapest ... to resolve" | Usually an unmeasured claim about effort. |
| "in terms of" | Almost always deletable. |
| "our own" | Pick one word. "Our" or "own", not both. |

**Internal path references.** Any `local/`, `audit-notes/`, or bare `.md` link is broken the moment
the document leaves the repository. Flagged whenever the destination is external.

**Positional references.** "the middle column", "the first table", "the section above". Name the
thing. Readers count differently, and structure changes.

**Word count.** Not a limit, a check against the tier. A memo over about 700 words has stopped being
a memo.

## What the linter cannot catch

**Meta-commentary about the document.** Sentences describing the document's own construction:
"Recorded so that a later reader does not re-derive this", "This section carries as much weight as
the findings", "Quoted in full because". Useful in working notes for agents, noise in a report for a
person. Delete.

**Counter-arguments that change nothing.** Attaching "the counter-argument to expect" to every claim
reads as hedging, and it buries the actual conclusion. Include one only where a reader might act
differently if the counter-argument held.

**Unsupported summary claims.** The most damaging failure, because it is invisible in the prose. A
summary that says "mostly in the clear" above a body showing most cases failing is worse than no
summary. After drafting, take each summary sentence and point at the section that supports it. If
you cannot, the sentence is wrong.

**Framing inherited from the prompt.** If the investigation began from a suspicion, phrases like
"the problem we expected to find" and "the central hypothesis" will leak into the deliverable. The
reader did not share the suspicion and should not have to unpick it. Report what is, not what was
feared.

**Dead-end framing.** "This cannot be determined" ends the reader's options. "Ask X, who owns it"
gives them one. Almost every unknown has a person attached; find them.

**Triads and parallel lists.** Three parallel clauses per sentence, three bullets per list, three
examples per point. Recognisable and monotonous. Vary the count, and use two when there are two.

**Hedged verbs.** "may potentially", "could arguably", "it appears that". State the confidence once,
explicitly, then write plainly. A confidence marker in a table beats a hedge in every sentence.

## Calibration

Some of these habits are appropriate in working notes and records written for agents to read back,
where completeness beats readability and meta-commentary genuinely helps. The rules here apply to
documents a person will read once, in order, and act on.
