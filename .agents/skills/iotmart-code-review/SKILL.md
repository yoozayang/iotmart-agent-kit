---
name: iotmart-code-review
description: Entry point for every IoTMart code review. Review an implementation against an Azure DevOps work item, ADO URL, task number, PR, or branch. Use whenever asked to review, audit, check a task implementation, or inspect a PR, before using code-review or differential-review. Reads the WI first, then runs the vendored code-review and, for high-risk changes, differential-review under the IoTMart overlay.
---
# IoTMart task-aware code review

Read `.codex/playbooks/code-review-overlay.md` before step 1; it overrides the vendored skills.

## 1. Intake
1. Parse the supplied ADO URL, WI ID, PR URL, branch or commit. An ID is an ADO work item, not a GitHub issue.
2. Read the WI (read-only):
   - `az boards work-item show --id <id> --org https://dev.azure.com/advantech-curation --expand relations --output json`
   - Comments: `az devops invoke --area wit --resource comments --route-parameters project='IoTMart 3.0' workItemId=<id> --api-version '7.1-preview' --org https://dev.azure.com/advantech-curation --output json`
   - Use Description, acceptance criteria, comments and linked items. If the WI cannot be read, report the blocker; do not invent requirements or claim a full task review.
3. Resolve the implementation:
   - First the `Development Handoff` section in the WI Description (repository, branch, PR, head commit).
   - Otherwise WI relations named `Pull Request`: the URL ends with the PR ID (`vstfs:///Git/PullRequestId/<project>%2F<repo>%2F<id>`, case-insensitive `%2F`). Read each with `az repos pr show --id <id> --org https://dev.azure.com/advantech-curation` for repository, `sourceRefName`, `targetRefName`, status.
   - Ignore abandoned PRs. One active PR: use it. Several active PRs or only completed ones without an obvious match: list them and ask which to review.
   - Otherwise a branch named in WI comments or elsewhere in the Description: verify it exists on the remote (`git ls-remote`) and carries the WI number before using it. Never guess a branch from the WI number alone.
   - Fetch the resolved branch when it is not available locally.
4. Diff base: merge-base with `origin/<targetRefName without refs/heads/>` when a PR is resolved, otherwise `origin/Dev`. Capture `git diff <base>...<head>` and `git log <base>..<head> --oneline` once; fail early on a bad ref or empty diff. Check uncommitted changes when reviewing local work.
5. Load context through `.codex/routing.md` only for systems the diff touches. When the diff touches Salesforce code or metadata, read `.codex/knowledge/salesforce-review-standards.md`.

## 2. Spec and Standards (`code-review`)
Run the vendored `code-review` skill (`.agents/skills/code-review/SKILL.md`) with the overlay overrides: Spec axis against the WI; Standards axis against the Salesforce standards and repo docs. Keep the two axes separate.

## 3. Risk classification and Security (`differential-review`)
Classify Salesforce changes with the risk table in `salesforce-review-standards.md`. Classify changes in other systems (Magnolia, SAP/SIS, scripts) with the upstream `differential-review` Risk Level Triggers, without loading that skill: HIGH = auth or permissions, crypto or secrets, external calls or integrations, value transfer (price, currency, payment), removed validation or error handling; MEDIUM = business logic, state changes, new public APIs; LOW = comments, tests, UI text, logging. Any HIGH makes the whole diff HIGH. HIGH: run the vendored `differential-review` skill (`.agents/skills/differential-review/SKILL.md`) with the overlay overrides. MEDIUM or LOW: do not load it; record the level and the reason.

## Rules
- Read-only. Do not deploy, retrieve, write data, edit code, post ADO/GitHub comments, or approve/merge a PR without the relevant authorization. Running tests or org operations follows existing playbooks and target-org authorization.
- Distinguish introduced defects from pre-existing issues; verify each finding against reachable callers, existing guards and tests. Do not invent findings.

## Output
- Context: WI ID/link, PR, repository, branch, base/head SHA, evidence limitations.
- Spec: requirement coverage per criterion (met / partial / missing / unverified), scope creep, wrong implementations.
- Standards: violations with the cited standard; smells as judgement calls.
- Security: risk level and reason; differential-review findings and report path when HIGH.
- Findings carry severity (Critical/High/Medium/Low), file:line, evidence, impact, recommended fix and verification; mark pre-existing ones separately.
- Tests: executed with results vs recommended but not executed.
- Verdict: ready / changes required / insufficient evidence. An unread WI means insufficient evidence for requirement compliance.
