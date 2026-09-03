# Reference

## Investigation escalation ladder

Stop at the first rung that gives a definitive, evidence-backed verdict. Escalate only when the current rung can't see the affected property.

1. **Resource metadata** — `az <service> list/show`, ARM properties, app settings, SKU/`kind`, `linuxFxVersion`, `functionAppConfig.runtime`. Fast; sufficient for most version/SKU notices.
2. **Live config / management APIs** — settings that aren't in the base resource object (e.g. Kudu VFS for code-deployed Function Apps: `GET https://<app>.scm.azurewebsites.net/api/vfs/site/wwwroot/<file>` with publishing creds). **Note:** Kudu/SCM is usually unavailable for custom-container apps — the code is baked into the image, not `wwwroot`.
3. **Container image** — when config is baked into a Docker image, read it from the image: pull and `docker create` + `docker cp` the file out, or extract it from the image layers. The registry may live in a **different subscription** (see Auth patterns).
4. **Source repo / IaC** — the durable source of the setting (e.g. `host.json`, Bicep/Terraform, Dockerfile, pipeline YAML). Confirm the fix location here; this is also where remediation will land.

Always ask: *does this resource even use the affected feature?* Some runtimes/configs are structurally exempt (documented per-example below). Exempt resources belong in the **not-affected** list with the reason.

## Worked examples

### A. Extension bundles v1/v2/v3 → v4 (Azure Functions) — *config not in metadata*
- **Type:** version deprecation. **Fix lives in:** `host.json` (`extensionBundle.version`), target range `[4.*, 5.0.0)`.
- **Investigate:** `az functionapp list`. Bundle version is **not** in resource metadata — escalate to rung 2 (Kudu, code apps) or rung 3 (pull image, container apps), or rung 4 (repo `host.json`).
- **False positives:** **.NET** apps (in-process `dotnet` or `dotnet-isolated`) don't use extension bundles at all — they reference NuGet packages. Exempt. Only non-.NET runtimes (Python/Node/PowerShell/Java) are affected.
- **Gotcha:** one source repo/image can back multiple apps (e.g. dev + prod off different tags) — one fix covers several apps.

### B. General-purpose v1 → v2 storage accounts — *trivially queryable*
- **Type:** SKU/kind retirement, hard deadline. **Fix:** upgrade account to GPv2 (an in-place operation).
- **Investigate:** `az storage account list --query "[?kind=='Storage'].{name:name,rg:resourceGroup,kind:kind}" -o table` (GPv1 = `kind=='Storage'`; GPv2 = `StorageV2`).
- **Watch for:** managed exceptions — e.g. Databricks-managed storage is migrated by Microsoft; don't plan manual work for those.

### C. Node.js (or Python) runtime end-of-support on Azure Functions — *location depends on hosting model*
- **Type:** runtime/language version end-of-support, hard deadline.
- **Investigate:** confirm the runtime (`FUNCTIONS_WORKER_RUNTIME`), then find the version — **where it lives depends on the hosting model, so check the model first** (`az functionapp show` → `reserved`, `kind`; `az functionapp config show` → `linuxFxVersion`; `functionAppConfig`):
  - **Windows code app** (`reserved=false`, empty `linuxFxVersion`): version is the **`WEBSITE_NODE_DEFAULT_VERSION` app setting** (e.g. `~22`) — *not* `linuxFxVersion`. An empty `linuxFxVersion` here means "Windows," **not** "no version set" — don't read it as not-affected.
  - **Linux code / container app** (`reserved=true`): `linuxFxVersion` (e.g. `Node|22`, `Python|3.11`). For **containers** the version comes from the **base image** — escalate to rung 3/4 (Dockerfile `FROM …:<runtime><ver>`, pipeline `UsePythonVersion`/node version).
  - **Flex Consumption** (`functionAppConfig` non-null): `functionAppConfig.runtime.name` / `.version`.
- **Gotcha (deps):** upgrading the runtime often forces dependency bumps (e.g. numpy 2.0 breaks older pyomo on Python 3.11) — flag that CI/tests must revalidate; don't assume a clean bump.
- **Gotcha (platform):** the target major may not be offered on the current plan/OS at the same time across Windows/Linux/Flex. Remediation can be a **platform migration**, not a one-line setting change — call this out as a risk/open question rather than promising a trivial fix.

### D. Action-group email OTP verification — *behavioral change, nothing to "upgrade"*
- **Type:** behavioral/policy change. No resource is on an "old version."
- **Investigate:** `az monitor action-group list` → inspect `emailReceivers`; identify **automation/processes that add email recipients** (runbooks, IaC, scripts). Impact is procedural: new recipients must complete OTP or they silently won't receive alerts.
  - **`status` ≠ verified:** `az` exposes each receiver's `status` (Enabled/Disabled) but **no OTP-verification-state field** — don't read `status: Enabled` as "verified." Verification can only be confirmed out-of-band (recipient completed the OTP, or a test notification arrives).
  - **Find the IaC** that provisions receivers: `az deployment group list`/`show` often reveals an `emailReceivers` array parameter (a Bicep/Terraform/AVM module), pointing to the source repo where the add-recipient process lives.
  - **Size the blast radius:** check what *consumes* the action group — `az consumption budget list` (→ `notifications.*.contactGroups`) and `az monitor metrics alert / scheduled-query / activity-log alert list`.
- **Plan focus:** process/runbook updates and owner awareness, not a config migration.

## Auth patterns (generic)

- **Azure CLI:** `az account show` to confirm identity; `az account list -o table` to find subscriptions; `az account set --subscription <id>`.
- **The signed-in identity may lack access** to a given DevOps org, registry, or subscription even when `az` is authenticated (service/automation accounts especially). Verify access early; re-auth as the right identity or use a PAT/admin creds where appropriate.
- **Azure DevOps token (AAD-backed orgs):** the org is tied to a specific tenant — get a token in **that tenant**:
  ```
  export AZURE_DEVOPS_EXT_PAT=$(az account get-access-token \
    --resource 499b84ac-1321-427f-aa17-267ca6975798 \
    --tenant <org-tenant-id> --query accessToken -o tsv)
  ```
  (`499b84ac-1321-427f-aa17-267ca6975798` is the well-known Azure DevOps resource ID.) Then use `az repos` / `az devops invoke`. Read files via the Git Items API; `az devops invoke --area git --resource pullrequests` is GET-only, so use `az repos pr create` to open PRs.
- **Cross-subscription container registry:** an app's image often lives in an ACR in a *different* subscription. Find it (`az acr show -n <acr> --subscription <sub>`), then pull using `az acr login` in the owning subscription, the registry's admin credentials (`az acr credential show`), or the app's own `DOCKER_REGISTRY_SERVER_*` settings.
- **Prefer read-only** during investigation; treat any write (branch, PR, config change) as remediation, which is out of scope for the triage run.

## Plan template

Write to `<date>-<slug>.md` (e.g. `2026-07-17-extension-bundle-v4.md`) in the confirmed output folder.

```markdown
# Azure notification triage — <short title>

**Notice:** <what is changing → target/replacement>
**Type:** version/SKU deprecation | runtime end-of-support | migration | behavioral change
**Deadline:** <date> (<N days/months out>) | none stated
**Tracking ID:** <id or n/a>
**Subscription(s):** <name(s) + id(s)>
**Reference:** <authoritative doc link(s)>

## Affected resources
| Resource | Location / RG | Evidence (how confirmed) | Fix lives in |
|---|---|---|---|
| ... | ... | e.g. host.json in image = v3 | repo/file |

## Not affected (with reason)
| Resource | Why exempt |
|---|---|
| ... | e.g. .NET runtime — doesn't use extension bundles |

## Remediation steps
1. <change> — where it's made, and how it deploys
2. Staged rollout: dev/nonprod first → verify → prod
3. ...

## Verification
- How to confirm the fix is live (re-read config / re-query metadata)

## Rollback
- How to revert (previous image tag, prior SKU, etc.)

## Open questions
- <unknowns blocking execution — deploy mechanism, ownership, dependency risk>
```

**For behavioral/policy notices**, this template is migration-shaped — adapt it rather than force-fit: rename **Affected resources** → *Exposure / affected processes*, read the *Fix lives in* column as *where a future change would land*, add a short *What "affected" means for this notice* preamble when nothing currently deployed breaks, and expect **Remediation** = process/owner/guardrail actions and **Rollback** = often N/A (Microsoft-side policy).

After writing, offer to draft a tracker task/ticket (Jira, GitHub issue, etc.) from the plan — but only create one if the user asks.
