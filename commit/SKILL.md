---
name: commit
description: Group changes into commits and write commit messages in the user's preferred style. Use when the user asks to commit changes, create commits, or write commit messages. Also load this upfront when starting a multi-step implementation task so commits made along the way follow the process.
---

# Commit

## Workflow

1. **Run `git status` and `git diff`** (staged + unstaged) to see all changes.
2. **Propose groupings + draft messages BEFORE committing.** Show one block per planned commit — files included, draft message — and wait for approval. Adjust based on feedback, then commit.
3. **Skip step 2** when the user signals they don't need to see the plan first ("one commit", "single commit", "squash these", "just commit it") — draft the message(s) and commit.

## Grouping

Each commit should be a cohesive set of changes that reads clearly when scanning `git log`. Tests with the feature is fine; tests as a separate commit is also fine — pick whichever reads better. Don't split for the sake of splitting; don't bundle unrelated changes.

## Message style

The default is **plain imperative subject lines** — short, specific, no decoration:

- `Add account page with auth-gated route and nav link`
- `Fix fetchAuthMe to handle non-JSON responses from /.auth/me`
- `Co-locate MSAL components and hook under shared/auth/`

Rules:

- One line. Capitalized imperative. No trailing period (unless splitting two sentences).
- Lead with the verb. Add detail only when it helps a reviewer scanning history.
- No `chore(scope):` / `fix(frontend):` / `refactor:` prefixes.
- No body. No `Co-Authored-By` trailer.

### Overrides

Deviate from the default only in these cases:

1. **Explicit instruction.** The user asks for a different style for this commit ("use conventional commits", "add a body explaining X", "include Co-Authored-By"). Follow what they asked.
2. **Strong repo convention.** The user's own recent commits consistently use another style. Check before deviating:

   ```
   git log --author="$(git config user.name)" --oneline -20
   ```

   Only infer style from the user's own commits — not from merge commits or other contributors. When in doubt, ask.

## Committing

- Stage explicit paths (`git add path/to/file`), not `git add -A` or `.`.
- Pass the message via `-m "..."` directly. No HEREDOC needed for single-line messages.
- Never use `--no-verify`, `--amend` (unless user asks), or `--no-gpg-sign`.
- If a hook fails, fix the underlying issue and create a new commit.
