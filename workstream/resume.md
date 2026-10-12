# resume

Pick a workstream back up, starting from verified state. Resume reads and reports. It changes nothing; park does the writing.

1. **Locate and read STATE.md only.** Read LOG.md, plans, or research only when a next action or a question needs them.
2. **Note its age**: days since `Updated:`. If `Status: done`, say so and ask whether to reopen before doing anything else.
3. **Run the live checks.** If the *Live checks* section is empty, skip this step. If the harness can delegate to a subagent on a lower-cost, faster model, hand it the *Live checks* section and the claims they verify. It runs the read-only commands and returns only the drift: each claim that no longer holds, what is true instead, and checks that failed to run. Otherwise run them in this session and keep only the drift. Never run a check that writes.
4. **Report**, in this order:
   - the state in one line
   - drift found by the checks, and any blocker whose resume trigger has now been met
   - the proposed next action, with its suggested model tier and effort; if this session runs on a different tier, say so in one line
5. **Wait for the user** to confirm the next action or pick another. Fold the drift into STATE at the next park rather than now.
