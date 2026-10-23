---
name: pr-description
description: Write or update a concise pull request title and description for the current branch, filling the repo's PR template when one exists, then run the prose pass and print the result for pasting. Use when the user asks for a PR description, to write up the PR, or to update the PR description after a push. Writes text only; it never pushes, creates, or edits a PR.
---

# PR Description

A description a reviewer reads before the diff: what the change does, and the key changes worth knowing. Not a file list, not testing steps. Never add attribution of any kind.

## 1. Gather

- **Base.** Use the base the user names. Otherwise the convention in the repo's agent instructions (CLAUDE.md and the files it imports). Otherwise `dev` if it exists, else the remote default branch. When the branch may stack on another (an epic or release branch), pick the candidate with the fewest commits in `git rev-list --count <candidate>..HEAD`. State the base used in one line; ask only on a tie.
- **Diff** against the merge base, the source of truth.
- **Commits** on the branch, for intent the diff can't show.
- **Session context**: a plan, shape doc, or review from this session, or in the open workstream folder. Use it for the why; trust the diff over it where they disagree.
- **Ticket ID** from the branch name (letters, dash, digits, e.g. `EN-4568`; uppercase the prefix). If there is none, ask for it.
- **Template**: `.azuredevops/pull_request_template.md`, `.github/pull_request_template.md`, or `docs/pull_request_template.md`, first found.
- **Existing description**: one the user pasted, else `pr-<branch-slug>.md` in the working-files location. If both, the pasted one wins; it is what's live.

## 2. Write

```md
<ID>: <one-line summary of the change>

<Intro: 1–3 sentences that orient the reader. What the change does and why.>

- <Key change, one sentence.>
- <Key change, one sentence.>
```

- **Title**: names the outcome of the change. The ID appears here only.
- **Intro**: the change as a whole, for someone who hasn't read the ticket.
- **Bullets**: the key changes, not every file or every condition handled. One sentence each by default. Add a second sentence or child bullets only for what a reader won't get from the diff: a gotcha, a non-obvious reason, a behavior change for existing callers, a risk or an untested area.
- Write for what a reviewer can see in the PR: no local paths, session refs, or skill names.

**Updating.** With an existing description, revise in place: keep the user's wording and tone, add or adjust bullets for what changed, and drop bullets the diff no longer supports. Regenerate only when asked.

## 3. Fill the template

When one exists, its headings and order are fixed. Comments are instructions: follow them, then delete them. The title and description go where the template leaves the body open.

Answer sections the diff can answer from evidence. For deployment or release steps, tick boxes from what the branch adds: migrations, hand-applied SQL, newly read env vars, infra or config changes. Fill only the lines that apply and delete the rest. Env var names only, never values. If the template expects a file the branch should add (a deploy-steps note for the ticket) and it's missing, say so in chat.

If the template asks for something this format can't supply (testing steps, much more detail, sections the diff can't answer), say so and stop rather than improvise.

## 4. Save and prose pass

Write to `pr-<branch-slug>.md` in the working-files location from the user's agent instructions, overwriting any earlier draft.

1. `scripts/check-prose.sh <file>`, see [PROSE.md](PROSE.md). Flags default to fix; keep one only deliberately, and say which and why. Weigh cadence, triad, and punchline flags against the intro only; bullets and template fields are meant to be clipped.
2. Hand the file to a subagent on a mid-tier model, briefed with [REWRITE.md](REWRITE.md) and told the document is a PR description whose title, bullets, and template headings stay as they are. Run the linter again on the result, and read it yourself.

## 5. Print

Print the final text in one fenced `md` block for pasting, then below it:

- the base used
- the file path
- anything flagged: a missing deploy-steps file, a prose flag kept, an assumption to check
