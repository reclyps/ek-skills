Default: a doc holds what its reader can't get from the code, git, or a CLI, and stays true when other files change.

Worth writing:
- **Rulings and why**: a decision, the rejected alternative, the trap that prompted it
- **Procedure**: the command, the example, the exact order, with the output a reader should expect
- **Out-of-repo state**: live cloud or database config, licensing, who owns what (name the owner)
- **Pointers**: a link or path to the source of truth instead of a copy

Never:
- **Counts and statistics** that drift ("about half the rules", rule totals, line counts, versions). Drop them, or say how to re-derive.
- **Another module's behavior as fact** ("CI Lint never fails"). State the local assumption and point at the file that enforces it.
- **Narrate the change**: "now", "no longer", "previously", "added for", session or plan refs. A ticket or ADR link is fine when it points at a ruling the reader needs.
- **Restate derivable content**: copied config values, directory listings, tables the source already has, signatures.
- **Time-bound claims without an owner or date** ("currently unlicensed"). Name who can confirm.
- **Example lists that will drift** ("Pipelines, CSS, YAML, …"). Name the category.
- **Facts in two docs.** One doc owns it; the other links.
- **Unverified specifics**: every path, command, flag, symbol and rule name must exist as written.

Agent-read docs (state docs, working files): name what you left out as derivable, once per doc. An omission looks identical to an oversight.

Length: short sections, examples over prose, link out instead of embedding a reference.

Test: would a reader a year out, who never saw this change, find it true, and could they not get it from the source?
