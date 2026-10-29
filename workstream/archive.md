# archive

Move a finished workstream out of the repository into the archive, so the live workstreams directory holds only work in progress. Also files any other working folder, such as pre-workstream clutter, under the same project.

1. **Resolve the archive root.** Pass `--root` to `scripts/archive.sh` when the user's arguments or agent instructions name a location; otherwise the script reads `WORKSTREAM_ARCHIVE_ROOT`. If it exits 2 for a missing root, ask the user where archives go and suggest they set the variable. Never pick a location yourself.
2. **Confirm it's finished.** Read STATE.md. If `Status:` isn't `done`, say what's still open and ask whether to park it as done first (follow [park.md](park.md)) or stop. A folder with no STATE.md skips this step.
3. **Check for loose ends.** Report uncommitted changes or unpushed commits on the workstream's branches. Archiving doesn't touch git, but the user should know before the folder leaves the repo.
4. **Write a one-line summary** for the index: the outcome and its ticket key, taken from *Goal* and *State*. For a folder with no STATE.md, base it on the files.
5. **Run** `scripts/archive.sh [--root <dir>] [--month YYYY-MM] <folder> <name> "<summary>"`. Pass `--month` when backfilling, using the month the work ended. The script refuses to overwrite an existing archive folder.
6. **Report** the new path. Files that cited the old path now point nowhere; list any you know of.
