---
name: iotmart-code-review
description: Review IoTMart code against an ADO work item, PR, branch, or commit. Entry for task and PR reviews; uses code-review and adds differential-review only for HIGH risk.
---
# IoTMart review

Read `.codex/playbooks/code-review-overlay.md` first for baseline, authorization, and upstream overrides.

## Intake
1. Read the WI via `.codex/playbooks/ado-work-item.md`. Use Description, acceptance criteria, comments, and relations. Unread WI means insufficient evidence for requirement compliance, not invented requirements.
2. Resolve implementation in order:
   - `Development Handoff` in Description: repository, exact branch, PR, head.
   - WI Pull Request relations: parse PR ID from `vstfs:///Git/PullRequestId/<project>%2F<repo>%2F<id>` (case-insensitive `%2F`); use `az repos pr show --id <id> --org <org>` for repository, source/target, status. Ignore abandoned PRs. One active PR: use it; multiple active or ambiguous completed PRs: ask which.
   - Branch explicitly named in Description/comments: verify remotely with `git ls-remote` and confirm WI number. Never guess from the WI number alone.
3. Fetch missing refs, use the overlay's diff base, and capture diff/commit list once. Bad refs: stop. Empty diff with no PR: report no implementation, skip code/security review, use `.codex/skills/requirement-review.md`.
4. Load only affected-system knowledge from routing. Salesforce changes add `.codex/knowledge/salesforce-review-standards.md`; do not load deployment/Notion workflows for review.

## Review
- Run `.agents/skills/code-review/SKILL.md` with overlay overrides.
- Classify Salesforce risk using its standards table. Other systems: HIGH = auth/permissions, crypto/secrets, external integration, value transfer, removed validation/error handling; MEDIUM = business logic, state changes, new public APIs; LOW = comments, tests, UI text, logging. Any HIGH makes the diff HIGH.
- HIGH: run `.agents/skills/differential-review/SKILL.md` with overlay overrides. Otherwise do not load it; report level/reason.
- Verify findings against reachable callers, existing guards, and tests; distinguish introduced defects from pre-existing issues.

## Output
- Context: WI/link, PR, repository, branch, base/head SHA, evidence limits.
- Spec: per-criterion met / partial / missing / unverified, scope creep, incorrect implementation.
- Standards: cited violations; smells labelled as judgement calls.
- Security: level/reason, HIGH findings/report path when triggered.
- Each finding: severity, file:line, evidence, impact, fix, verification; mark pre-existing issues.
- Tests: executed/results vs recommended/unexecuted. Verdict: ready / changes required / insufficient evidence.
