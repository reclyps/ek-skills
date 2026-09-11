# ek-skills

## Shared files

`_shared/prose/` holds the canonical prose checker, its reference doc, and the rewriter brief.
Consuming skills symlink them, so there is one copy to edit and every skill directory still stands
on its own.

`_shared/` is deliberately not symlinked into `~/.claude/skills` — it is not a skill and must not
route.

**Package with `zip -r`.** It dereferences symlinks by default, so each skill extracts as real
files. Do not use `zip -y`, `tar` without `-h`, or `git archive` — all three preserve the symlinks
and ship a skill that dangles on someone else's machine.
