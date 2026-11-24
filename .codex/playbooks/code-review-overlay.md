# Review overrides

Review starts at `iotmart-code-review`, including direct invocation of either upstream review skill.

## Baseline and permissions
- Spec: ADO WI Description/acceptance criteria from intake, not PR prose or inferred intent. Skip upstream tracker setup, commit-message issue discovery, and asking for an already-read spec.
- Diff base: explicit user base > PR target > system default (Salesforce: `origin/Dev`; Magnolia: `origin/main`; personal repo: default branch). Identify the repository/system before choosing a base; compare from its merge-base with head. Check local uncommitted changes; verify refs and non-empty diff before review. Intake handles empty/unresolved cases.
- Git diff does not establish target-org state.
- Review is read-only: no code edits, retrieve, data writes, deploy/validation/dry-run, external comments, PR approval, or merge. Separately authorized tests/org operations first load their own rules. The HIGH report below is the only review write.

## Upstream adaptation
- `code-review` is always the primary framework. Preserve separate Spec and Standards reports; do not merge/rerank them.
- Standards: repo docs plus Salesforce standards when affected; documented rules override upstream smell heuristics.
- Run both axes in fresh parallel subagents when supported/authorized; otherwise Spec then Standards with independent sources.
- Map Salesforce security checks to its HIGH table; skip smart-contract-only patterns.
- `differential-review` report: `~/codex_tmp/review/<WI or branch>/DIFFERENTIAL_REVIEW_REPORT.md`, never in the repo. Read `adversarial.md`; unavailable adversarial-modeler/audit-context-building/issue-writer integrations are skipped. Example time estimates are not targets.
- Missing vendored files: report the gap and use these available rules; do not claim full upstream coverage. Review does not replace handover evidence assessment.
- Maintenance only: sources/pins/licenses are in kit-root `review-skill-sources.json`.
