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
