# init

Create a workstream for a piece of work, of any size.

1. **Name it.** Use the name the user gave, as a short slug (an epic key, `billing-migration`). If none was given, propose one and confirm.
2. **Locate it.** Run `scripts/locate.sh [--root <dir>] <name>`. If the folder already exists, stop and offer `resume` instead.
3. **Create the folder**: `STATE.md` copied from [TEMPLATE.md](TEMPLATE.md), an empty `plans/` and `research/`, and `LOG.md` containing only `# <name> log`.
4. **Keep it out of version control.** Inside a git repository, run `git check-ignore -q <workstreams-dir>`. If it is not ignored, tell the user, then append the workstreams directory, relative to the main checkout root, to `$(git rev-parse --git-common-dir)/info/exclude`. That file is local to the clone, so no shared ignore file changes.
5. **Fill what is known.**
   - Goal: from the user's arguments, the conversation, or the defining ticket if a tracker is reachable.
   - Decisions, gotchas, and blockers: from the conversation, when the work is already under way.
   - An existing handoff or notes file: migrate its state into the template's sections, move narrative history into LOG.md as a single entry, and leave the original file untouched.
   - Leave empty sections empty. Don't invent content to fill them.
6. **Add live checks** for every external system the work touches that has a read-only CLI or API the session can already reach. Skip any that would need new credentials and list them as a gap.
7. **Validate.** Run `scripts/check.sh <STATE.md>` and fix until it passes.
8. **Report** the folder path, the first next action with its model tier, and the resume command: `/workstream resume <name>`.
