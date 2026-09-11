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

## Installing

```bash
./install.sh              # install into every agent directory
./install.sh --dry-run    # show what would change
./install.sh --no-prune   # keep skills that have left the repo
```

Each skill is installed as a real directory whose files are symlinks back to this repo, into
`~/.claude/skills` and `~/.agents/skills`. Agent skill scanners list directory entries and filter on
`isDirectory()`, which is false for a symlinked directory — so a symlinked skill folder is invisible
to some harnesses, GitHub Copilot CLI among them. A real directory passes that filter, and every
reader follows the file symlinks inside it.

Because the files are links, **editing a skill takes effect immediately**. Re-run `install.sh` only
when a file or a skill is added, removed or renamed.

It touches nothing it did not create: installs are stamped with a `.ek-skills-managed` marker, and
only marked directories are replaced or pruned. Skills installed by `npx skills` and hand-made
directories are left alone.
