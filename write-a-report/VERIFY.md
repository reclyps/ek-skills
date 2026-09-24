# Brief: QA subagent

The last gate, after the rewrite and the linter. Mid-tier model; top tier when the deliverable is
legal, compliance, or financial.

**Pass it:** every document going to the reader — the memo and the reference document both, where
the output was tiered — and paths to the source evidence: research notes, data files, transcripts,
the underlying documents. It cannot check support without the material.

**Withhold:** the brief, the framing agreed with the user, and any account of why the conclusion
holds. It must not learn what answer it is meant to reach. The risk with a subagent is not stale
context, it is a brief that leaks the conclusion and turns the check into a confirmation.

Findings go to a scratch path outside the repository. The orchestrating agent reads them and applies
the fixes. The user never opens this file.

---

## Prompt

> Quality-check the documents at `<DOC_PATHS>` against the evidence at `<EVIDENCE_PATHS>`. Assume
> they are wrong and find where. Do not edit them.
>
> ### 1. Arithmetic
>
> Recompute every number by writing and running a Python script. Do not check arithmetic by reading
> it.
>
> - Totals against their components
> - Percentages against the base they are taken from
> - Unit conversions, currency conversions, rates
> - Durations, dates, and intervals
>
> Report each as: stated value, recomputed value, and the line it appears on.
>
> ### 2. Claim support
>
> For every assertive sentence — the opening paragraph, every heading, every summary bullet, every
> topic sentence — find the material below it, and the evidence behind that, which supports the
> claim. Give one of three verdicts:
>
> - **Supported.** Quote the line that carries it.
> - **Overstated.** The material supports something weaker. Write out the weaker claim, as a
>   sentence that could be dropped straight into the document.
> - **Unsupported.** Nothing below it supports it, or the material contradicts it. Say which.
>
> The overstated verdict is the one that matters most. A misleading headline is rarely false; it is
> directionally right and stronger than its section earns. Always supply the replacement sentence.
>
> ### 3. Consistency, within and across documents
>
> These documents are read together, and a reader who spots them disagreeing stops trusting both.
>
> - Any figure appearing more than once, in either document, must be identical everywhere.
> - Every conclusion in the short document must match the determination the long one reaches. Where
>   the short one is necessarily coarser, it must not be stronger.
> - Caveats and qualifications present in the long document must not have been dropped from the
>   short one where they change what a reader would do.
> - Cross-references must resolve, and named owners and dates must agree.
>
> ### 4. Fact against inference
>
> Flag anything asserted as established that is actually inferred, extrapolated, or assumed.
>
> ### Output
>
> Write findings to `<SCRATCH_PATH>`, ordered most serious first, each with the document, the line
> number, and the correction or replacement sentence. Do not modify the documents.
>
> Return a summary under 100 words: how many figures you checked, how many were wrong, how many
> claims were overstated or unsupported, and whether the documents agree.
>
> You have not been told what conclusion these documents are supposed to reach. Do not try to work
> it out, and do not resolve ambiguity in their favour.
