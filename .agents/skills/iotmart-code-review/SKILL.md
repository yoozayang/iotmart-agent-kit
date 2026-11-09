---
name: iotmart-code-review
description: Review an IoTMart implementation against an Azure DevOps work item, ADO URL, task number, PR, or branch. Use whenever asked to review, audit, check a task implementation, or inspect a PR. Read task requirements first and apply the shared IoTMart rules.
---
# IoTMart task-aware code review

## Intake and source of truth
1. Parse the supplied ADO URL, task ID, PR URL, branch or commit. Do not assume an ID is a GitHub issue number.
2. If an ADO ID or URL is supplied, retrieve the actual work item through available Azure DevOps integration or authorized tooling. Read description, acceptance criteria, comments, linked work items, attachments and relevant history; cite accessible source references. If unavailable, report the blocker and request the work-item content; do not fabricate requirements or claim a full task review.
3. Resolve linked PR, branch, commits and repo. If multiple candidates exist, ask which one. Check working-tree state and uncommitted changes when reviewing local work.
4. Read `AGENTS.md`, `.codex/routing.md`, `.codex/playbooks/git-baseline.md`, relevant knowledge and playbooks. For IoTMart branch-change review use `origin/Dev...HEAD` by default, not main. Git diff describes code changes, not target-org state.
5. Build a compact traceability map: acceptance criterion -> implementation location -> test/evidence -> status. Mark missing or ambiguous requirements explicitly.

## Review execution
- First inspect scope and tests, then changed code and callers, error paths, security, maintainability, performance, regression risk, and Salesforce-specific behavior.
- Use the read-only quality framework from `code-review-and-quality` when installed. For security-sensitive changes, use `differential-review` when installed. For review delegation, use `requesting-code-review` only when supported; otherwise review directly. Missing optional upstream skills must not block baseline review.
- Follow `.codex/playbooks/code-review-overlay.md` for local overrides and provenance. Never run an upstream skill's commands in conflict with kit constraints.
- Review is read-only by default. Do not deploy, retrieve, write data, edit code, post ADO/GitHub comments, or approve/merge a PR without the relevant authorization. Running tests or org operations follows existing playbooks and target-org authorization.
- Distinguish introduced defects from pre-existing issues; verify each finding against reachable callers and existing guards/tests. Do not invent findings. Prefer actionable evidence over stylistic opinions.

## Output
- Context: task ID/link, PR/branch, base/head SHA, evidence availability and limitations.
- Requirement coverage: met / partial / missing / unverified for each criterion.
- Findings: severity (Critical/High/Medium/Low), file:line, observed evidence, impact, recommended fix and verification. Mark pre-existing findings separately.
- Tests: executed with results vs recommended but not executed.
- Verdict: ready / changes required / insufficient evidence. Missing ADO content means insufficient evidence for requirement compliance, even if code quality was assessed.
