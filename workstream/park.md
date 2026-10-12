# park

Record where things stand so a fresh session can pick up. Run it at the end of a session, and whenever work stops on a blocker.

1. **Re-read STATE.md from disk.** Another session may have changed it since this one started; merge rather than overwrite.
2. **Rewrite STATE in place** to describe now:
   - `Updated:` today. `Status:` per SKILL.md. Use `done` only when the session's latest state shows nothing left; then *Next actions* reads `None`.
   - *State*: replace rather than extend.
   - *Blockers*: add new ones with owner and resume trigger; remove cleared ones.
   - *Next actions*: reorder and re-tier. The first item is what the next session does.
   - *Decisions*: add what the user decided this session, with the reason.
   - *Gotchas*: add traps hit this session that a later session would hit again.
   - *Live checks*: add a check for any new external fact; replace copied values with checks.
   - Delete anything no longer true. Don't strike it through.
3. **Append one LOG entry**: `## YYYY-MM-DD: <one-line summary>`, then at most five bullets covering what changed, what was ruled out and why, and any correction to an earlier belief. This is the only place history goes.
4. **Check the working tree.** Report uncommitted changes and unpushed commits, with branch and worktree. Don't commit or push unless the user asks.
5. **Validate.** Run `scripts/check.sh <STATE.md>` and fix until it passes.
6. **Hand over.** End with:
   - one line on the state
   - the resume command: `/workstream resume <name>`
   - the model tier and effort the first next action suggests
   - a recommendation to start the next session fresh instead of continuing this one, especially when the next action waits on a blocker. A long-idle session reloads its whole context on return, and stale context competes with STATE.
