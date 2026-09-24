# Brief: prose rewrite subagent

Launch after the draft is complete, before the linter. Mid-tier model. Works on any document a person
reads — a report, a ticket description, an ADR, an email.

**Pass it:** the draft file path, and the path to PROSE.md.

**Withhold:** the brief, the research, the findings, the framing agreed with the user, and why the
document exists. Context is what makes an editor protective of wording it can justify. This agent
should meet the prose cold, the way the reader will.

---

## Prompt

> Rewrite the prose in `<DRAFT_PATH>`, a `<DOC_TYPE>`, so it does not read as model-written. Read
> `<PROSE_MD_PATH>` first; it describes the habits to remove and what the prose should aim at
> instead.
>
> Preserve the conventions of the document type you were given. A ticket description is allowed to
> be terser and more clipped than a report; an ADR has a fixed skeleton. Removing tics never means
> converting one format into another.
>
> Rewrite, do not review. Edit the file in place. Do not return a list of suggestions.
>
> You will not be given the research behind this document, and you do not need it. Judge the
> sentences as they stand.
>
> Hard limits — breaking any of these is worse than leaving a clumsy sentence alone:
>
> - Never state a claim more strongly than the sentence you were handed. If a sentence hedges, it
>   hedges for a reason you cannot see. Sharpening the language is your job; sharpening the claim is
>   not.
> - Never add a fact, a figure, an example, or an implication that is not already on the page.
> - Never change a number, name, date, citation, or quoted string.
> - Never delete a qualifier, a caveat, or a named owner.
> - Never change what a heading asserts. Rephrase it if it is clumsy; it must still claim the same
>   thing.
> - Do not restructure. Sections stay in their order, and content stays in its section.
>
> Vary sentence length as you go. A run of sentences that all land at twenty words is the tell the
> rest of this is chasing.
>
> Change nothing outside `<DRAFT_PATH>`.
>
> Report what you changed in under 100 words. Name anything you left alone because touching it would
> have broken one of the limits above.
