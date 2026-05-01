---
name: commit
description: Group changes into commits and write commit messages in the user's preferred style. Use when the user asks to commit changes, create commits, or write commit messages. Also load this upfront when starting a multi-step implementation task so commits made along the way follow the process.
---

# Commit

## Workflow

1. **Run `git status` and `git diff`** (staged + unstaged) to see all changes.
2. **Propose groupings + draft messages BEFORE committing.** Show the user one block per planned commit — files included, draft message — and wait for approval. Adjust based on feedback, then commit.
3. **Skip step 2** if the user said "one commit" / "single commit" / "squash these" — just draft the one message and confirm.

## Grouping

Each commit should be a cohesive set of changes that reads clearly when scanning `git log`. Tests with the feature is fine; tests as a separate commit is also fine — pick whichever reads better. Don't split for the sake of splitting; don't bundle unrelated changes.

## Message style

- One line. 1-2 sentences max. No body.
- Imperative, capitalized. No trailing period on a single sentence; use a period only to separate multiple sentences.
- Lead with the action and scope. Add detail only when it helps a reviewer scanning history.
- **No `Co-Authored-By` trailer. Ever.**

Examples:
- `Add account page with auth-gated route and nav link`
- `Fix fetchAuthMe to handle non-JSON responses from /.auth/me`
- `Add account page`

## Committing

- Stage explicit paths (`git add path/to/file`), not `git add -A` or `.`.
- Pass the message via `-m "..."` directly. No HEREDOC needed for single-line messages.
- Never use `--no-verify`, `--amend` (unless user asks), or `--no-gpg-sign`.
- If a hook fails, fix the underlying issue and create a new commit.
