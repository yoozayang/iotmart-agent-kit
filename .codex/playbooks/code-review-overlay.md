# Code Review Overlay

This is the IoTMart-specific override for third-party review skills. `AGENTS.md` and task-specific playbooks take precedence. Keep upstream skill files unmodified.

## Baseline and evidence
- ADO task description and acceptance criteria are the requirement baseline when provided; do not substitute branch name, PR prose, or inferred intent.
- For IoTMart branch diff use `origin/Dev...HEAD` unless explicitly instructed otherwise. Inspect merge-base and uncommitted changes. For personal repos follow their own default branch.
- An org comparison requires actual target-org files and authorized retrieval; Git diff is not proof of deployed org differences.
- Read-only review is default. No silent deploy, data modification, Salesforce validation/dry-run, PR approval, or merge.
- Keep existing `validation-review.md` for handover evidence assessment; code review does not replace it.

## Review skill selection
- `code-review` (Matt Pocock): primary, separate WI spec and repository standards findings. IoTMart's ADO WI and `origin/Dev` baseline override the upstream skill's generic tracker/fixed-point assumptions. Run sequentially when subagents are unavailable.
- `code-review-and-quality` (Addy Osmani): additional correctness, maintainability and quality checks; avoid duplicating primary findings.
- `differential-review` (Trail of Bits): only for security-sensitive, authorization, data-access, API, integration, or high-blast-radius changes.
- Keep the three upstream names unchanged; the IoTMart wrapper remains `iotmart-code-review`.
- These are selected upstream references, not installed copies. Never claim they ran unless the files/tools are actually available. The wrapper must still perform its baseline review.

## Maintenance-only source registry
For exact upstream repository URLs, skill paths, source file blob SHAs, installation status, and update procedures, read `review-skill-sources.json` **only when installing, auditing provenance, or checking/updating review skills**. Do not load it for ordinary WI reviews.

When installing, preserve each original skill name and directory under `.agents/skills/`, keep vendor content unmodified, verify license and dependencies, and record exact pinned commit, hash, license and notices in the existing skills lock/notice mechanism. Update via pinned upstream re-import and diff; no rebase requirement. Existing `upstream-check.yml` currently excludes these names: extend its allowlist and checks before claiming automated updates. Treat executable or safety-relevant upstream changes as requiring review, not silent auto-merge.
