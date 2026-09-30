Default: no comment. Names, types, and structure show the *what*; a comment is justified only when it says what they can't.

Worth writing:
- **Why**: a non-obvious reason, constraint, or rejected alternative ("not X, because Y")
- **Warning**: what breaks if this changes (ordering, concurrency, perf cliff)
- **Workaround**: the quirk or bug, with a link
- **Contract** on public interfaces: units, nullability, side effects, errors. What a caller must know, not how it works

Never:
- Narrate the change: "now", "updated to", "previously", "added for", ticket/plan/session refs. Explanations of the change go in chat or the PR.
- Restate the code or the name.
- Describe another module's behavior ("the client retries 3x, so…"). State the local assumption, or enforce it with an assert/test.
- Comment around unclear code. Rename or extract first.

One line is normal; past ~3 lines, change the code or move it to a doc.
Test: would a reader a year out, who never saw this task, need this, and would it stay true if a different file changed?
