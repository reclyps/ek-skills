# Prose tells and what they indicate

The linter counts the mechanical ones. This file explains what each signal means and covers the
judgement calls a script cannot make.

**Flags default to fix.** Earlier versions of this file called them "signals, not errors" and told
the drafter to use judgement. In practice that gave every flag an exit, and the tics shipped anyway.
So: fix what the linter flags. Where a flag is genuinely a deliberate choice, keep it and name it in
which flag and why. The user overrules the linter. The drafter does not.

Individually none of these habits is a crime. One em-dash is fine; forty in a document is a tell.
The aggregate is what makes prose feel machine-written and tiring to read.

## What the linter flags

### Mechanical

**Em-dash density.** The single strongest tell. Reach for a comma, a colon, or a full stop first.
Above roughly one per 200 words, the prose starts to feel breathless. A document with 114 of them
was described by its reader as painful.

**Consecutive bolded paragraph openers.** Starting every paragraph with a bolded thesis makes the
reader feel shouted at, and it flattens emphasis so nothing stands out. Use headings for structure
instead. Two or three across a long document is fine; one per paragraph is not.

**Word count.** Reported, never scored on its own, and never something to write towards. Cutting a
working sentence to move the count trades readability against a proxy for it, and a document that
runs long has a section too many rather than sentences too fat. What counts as too long belongs to
the document type, so the linter only flags a length when the caller passes `--max-words`.

### Filler

Phrases that add no information. Each pattern is a regex, so inflections and hyphen-or-space
variants are caught too.

| Phrase | Why it goes |
| --- | --- |
| "worth noting / recording / stating / mentioning" | If it were not worth saying, it would not be in the document. Say the thing. |
| "It is worth" anything | Same. |
| "genuinely", "materially", "meaningfully", "significantly" | Intensifiers that let a weak claim pass as a strong one. |
| "That said", "Note that", "Of course", "Indeed", "To be clear" | Filler transitions. |
| "in terms of" | Almost always deletable. |
| "our own" | Pick one word. |
| "may potentially", "it appears that", "somewhat", "relatively" | Hedges. State confidence once, then write plainly. |

### Register

The house voice of a model writing about engineering work. Not wrong, but unmistakable, and it
reads as borrowed swagger anywhere a non-engineer is the reader.

Operational verbs: **landed**, **shipped**, **rolled out**, **surfaced**, **wired up**. Say what
happened. "Deployed on 3 September", "the review found three issues".

Appraisal constructions: **is real**, **the real risk**, **load bearing**, **buys you**, **earns its
place**, **carries weight**, **X beats Y**, **cheap to fix**. These assert importance rather than
demonstrating it. Give the reader the fact and let them weigh it.

Idiom the reader did not ask for: **non-trivial**, **the ask**, **the delta**, **table stakes**,
**blast radius**.

**Used in moderation.** A second group is idiom people genuinely say, where repetition rather than
presence is the tell. The linter tolerates one use and flags the rest, with substitutions attached —
four uses need three replacements, not four deletions.

| Phrase | Reach for |
| --- | --- |
| at a high level | conceptually, broadly, in outline, what rather than why |
| under the hood | internally, in the implementation |
| out of the box | by default, unconfigured |
| moving parts | components, dependencies |
| surface area | scope, exposure |
| happy path | the normal case |
| first-class | supported directly, built in |

"At a high level" is deliberately tolerated rather than banned: it is part of how the author of
these skills writes, and `write-a-ticket` uses "high-level" as the name of a mode. A linter that
flags its user's own idiom trains the model away from the voice it exists to protect. Do not move it
back to zero tolerance.

Corporate and brochure vocabulary: **leverage**, **utilize**, **robust**, **seamless**,
**comprehensive**, **holistic**, **granular**, **actionable**. And the essay register a model falls
into when it thinks it is being serious: **delve**, **underscore**, **pivotal**, **testament**,
**landscape**, **realm**.

### Structure

The tells you cannot reach with a word list. These are what make a document read as model-written
even after every banned phrase is gone.

**Antithesis.** "It isn't a config problem; it's a design problem." "Not a bug, but a choice."
"A recommendation, not a decision." The correction cadence: set up a wrong reading, knock it down,
land on the right one. Once in a document is rhetoric. Four times is a tic. State the thing
positively and delete the strawman.

**Adverb-comma openers.** "Notably,", "Critically,", "Importantly,", "Crucially,", "Ultimately,",
"In practice,", "Put simply,". They tell the reader how to feel about a sentence instead of writing
a sentence worth feeling that way about. Delete the opener; the sentence survives.

**Colon labels.** "The upshot:", "The catch:", "Bottom line:", "What this means:". A heading in
disguise. Either it is a section, or it is a sentence.

**Punchline fragments.** A three-word sentence dropped after a twenty-five-word one, for emphasis.
"That matters." "It works." "Nobody checked." Effective once per document, exhausting at five.

**Triads.** Three parallel clauses per sentence, three bullets per list, three examples per point.
Recognisable and monotonous. Vary the count, and use two when there are two.

**Repeated paragraph openers.** Four paragraphs starting "The" is a rhythm the reader feels without
being able to name.

**Cadence.** The deepest one, and the reason the others persist. Model prose parks at 15 to 25 words
per sentence with very little variation, so every sentence lands with the same weight and the reader
stops distinguishing between them. The linter reports mean, standard deviation, coefficient of
variation, and the share of sentences in the 12-28 word band. Uniformity alone is fine in a terse
document; uniformity plus most of the document sitting in that band is the tell. The fix is not a
rewrite, it is variance: put a six-word sentence next to a thirty-word one and let the short one
carry the point.

### References

**Positional references.** "the middle column", "the first table", "the section above". Name the
thing. Readers count differently, and structure changes.

**Internal paths.** Any `local/`, `audit-notes/`, or bare `.md` link breaks the moment the document
leaves the repository. Ignore the flag if the destination is a repo file.

## What the linter cannot catch

The largest of them — a summary claim the body does not support — needs a verification pass rather
than a reader's eye; `write-a-report` has one, and any skill producing documents with numbers and
findings in them wants something equivalent. What follows is what neither the script nor such a pass
will reach.

**Meta-commentary about the document.** Sentences describing the document's own construction:
"Recorded so that a later reader does not re-derive this", "This section carries as much weight as
the findings", "Quoted in full because". Useful in working notes for agents, noise in anything a
person reads. Delete.

**Counter-arguments that change nothing.** Attaching "the counter-argument to expect" to every claim
reads as hedging, and it buries the actual conclusion. Include one only where a reader might act
differently if the counter-argument held.

**Framing inherited from the prompt.** If the investigation began from a suspicion, phrases like
"the problem we expected to find" and "the central hypothesis" will leak into the deliverable. The
reader did not share the suspicion and should not have to unpick it. Report what is, not what was
feared.

**Dead-end framing.** "This cannot be determined" ends the reader's options. "Ask X, who owns it"
gives them one. Almost every unknown has a person attached; find them.

## Aim at

Proscription alone does not work. A model told to avoid twenty phrases produces a twenty-first. What
the prose should look like:

- **Sentences make claims a reader could disagree with.** "Retention exceeds the cap in three of
  four systems" invites a check. "Retention is a real concern" does not.
- **Verbs are literal.** Something was deployed, deleted, asked, refused, measured. It was not
  surfaced, landed, or unlocked.
- **Named actors and dates.** "Priya Raman expects to reply this week" beats "clarification is
  pending".
- **Length varies because the content varies.** A finding needs a clause; a caveat needs a
  paragraph. Do not even them out.
- **Nothing announces its own importance.** No "critically", no "the key point is". Put the
  important thing first and let position do the work.

## Calibration

Some of these habits are appropriate in working notes and records written for agents to read back,
where completeness beats readability and meta-commentary genuinely helps. Everything here applies to
documents a person will read once, in order, and act on — a report, a memo, a ticket description, an
ADR, an email.
