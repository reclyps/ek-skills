---
name: azure-notification-triage
description: Triage an Azure notification email (Action required / Action recommended / End of support / retirement) — parse it, identify which of the user's Azure resources are actually affected with evidence, and write an action plan. Use when the user shares or points to an Azure notification/service-health email about a deprecation, retirement, end-of-support, migration, or behavioral change, and wants to know what to do about it. Investigates and plans only; does not execute changes.
---

# Azure Notification Triage

Turn one Azure notification email into an evidence-backed action plan. **Investigate and plan only — do not execute changes.** Remediation (PRs, config edits, redeploys) is a separate phase the user kicks off explicitly.

## Input

The email arrives as **pasted text** or a **file path**. For files: parse `.eml`/`.html`/`.txt` directly (extract the readable body, strip markup); if `.msg`, ask the user to export it to text first.

## Workflow

### 1. Parse the notification
Extract and restate in 1–2 lines:
- **What is changing** (the deprecated/retired/changed thing) and its **target/replacement**
- **Deadline** and any **tracking ID** (may appear only in mail headers, e.g. `X-Mailgun-Tag`, not the visible body)
- **Doc links** (the authoritative how-to)
- **Account Information** block — `Subscription ID` / `Subscription name` (usually present; may be truncated or absent)

Classify the notice — this drives investigation:
- **Version / SKU / runtime deprecation** — a property you can query (storage `kind`, runtime version, API version, extension bundle…).
- **Behavioral / policy change** — no "old version" to find; identify *usage* and *process impact* instead (e.g. new OTP verification for action-group email recipients).

For a behavioral/policy notice — especially one that **grandfathers existing config** — the deliverable is **awareness + process guardrails**, not a resource fix. Expect the *affected* list to be small or empty while the *not-affected* list and the "who could trip over this next" analysis carry the value. Don't manufacture affected resources to fill a table.

### 2. Preflight & scope
- Confirm `az` auth: `az account show`. If the fix may live in source repos or registries, confirm those credentials too. See [REFERENCE.md](REFERENCE.md) → **Auth patterns**.
- Set the **target subscription** explicitly (`az account set`) and re-check with `az account show` — **mandatory**, not optional. The signed-in default is frequently a *different subscription and tenant* than the email's target, so investigating without setting it risks scanning the wrong subscription entirely. Prefer the Subscription ID/name from the email; otherwise ask. If several subs are named, handle each.
- Stay alert that **dependencies cross subscription boundaries** — a resource's container registry, storage, or key vault may live in a different subscription.

### 3. Investigate (evidence-based)
- Enumerate what the notice's criteria point at — candidate **resources** for a version/SKU/runtime notice; the **usage, consumers, and automation/processes** for a behavioral notice.
- **Batch and pace the queries.** Prefer one wide read (`az resource list --query`, or `az graph query` where the resource-graph extension is available) over a per-resource `show` loop. ARM throttles wide fan-out with HTTP 429 — back off and retry rather than treating the failure as a verdict. A 429 is not "not found".
- **Confirm actual deployed config, not just metadata.** When the affected property isn't visible in resource metadata, **escalate** — see [REFERENCE.md](REFERENCE.md) → **Investigation escalation ladder** (config API / Kudu → container image → source repo / IaC).
- **Rule out false positives explicitly** (e.g. a runtime that doesn't use the affected feature at all).
- **Resolve indirection before declaring anything orphaned or unused.** App settings and connection strings are frequently Key Vault references (`@Microsoft.KeyVault(SecretUri=…)`, `VaultName=…;SecretName=…`) — resolve them to the actual vault and secret before concluding a vault has no consumers. Resources also get renamed: a name from the email that doesn't resolve is not proof of absence. Search by resource ID or tag across resource groups, and check the activity log for a rename or move, before reporting anything as gone.
- Record **evidence for every verdict** — both affected and not-affected.

### 4. Write the action plan
- **Confirm the output location with the user**, then write `<date>-<slug>.md` using the template in [REFERENCE.md](REFERENCE.md) → **Plan template**. Suggest the current folder as a default — but **don't default to the folder the email/source files live in** (e.g. a directory of `.eml` files); propose a dedicated plans/output location instead.
- Include: summary + deadline/urgency, affected resources (with evidence), **not-affected (with reasons)**, remediation steps, verification, rollback, open questions.
- After writing, **offer** to also draft a tracker task/ticket from the plan (don't create one unprompted).

### 5. Prose pass

The file exists now, so run the prose pass over it.

1. `scripts/check-prose.sh <file>` — see [PROSE.md](PROSE.md) for what each flag indicates. Flags
   default to fix; keep one only deliberately, and say which and why.
2. Hand the file to a subagent (or a separate session, where the harness has none) briefed with
   [REWRITE.md](REWRITE.md), on a mid-tier model, telling it the document is an Azure remediation
   action plan so it preserves the format. Then run the linter again on the result.

The plan is mostly tables and lists. Weigh the cadence, triad and punchline flags against the
summary and the open questions, and ignore them where they land on the resource tables or the
numbered remediation steps.

The `prose-pass` skill is the same machinery if you want it on its own.

## Principles
- The plan is the deliverable — don't make changes.
- Azure emails are broad and often alarmist; the **not-affected list with reasons** is as valuable as the affected list.
- Prefer read-only investigation. Confirm scope before touching anything outward-facing.

See [REFERENCE.md](REFERENCE.md) for worked examples, the escalation ladder, auth patterns, and the plan template.

