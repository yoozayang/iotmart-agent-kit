# Code Review Overlay

IoTMart overrides for the vendored review skills `code-review` (mattpocock/skills) and `differential-review` (trailofbits/skills). `AGENTS.md` and task-specific playbooks take precedence. Upstream files under `.agents/skills/` stay unmodified; every IoTMart adjustment lives here.

## Entry and roles
- Every review starts from `iotmart-code-review`. When `code-review` or `differential-review` is triggered directly, apply this overlay and the wrapper intake first.
- `code-review` (Matt Pocock): primary framework, always used. Two separate axes: Spec and Standards.
- `differential-review` (Trail of Bits): security review, only when the wrapper's risk classification is HIGH.
- `code-review-and-quality` (Addy Osmani): methodology reference only, not installed and not loaded.
- If a vendored skill folder is missing (for example an old copy-mode install), say so and still follow the steps below.

## Baseline and evidence
- ADO WI Description and acceptance criteria are the requirement baseline; do not substitute branch name, PR prose, or inferred intent.
- Diff base: merge-base with the PR `targetRefName` when a PR is resolved, otherwise `origin/Dev...HEAD`. A resolved PR target counts as an explicitly specified base, so the `git-baseline.md` ban on `origin/main` as a default base does not apply to it. Personal repos use their own default branch. Inspect uncommitted changes when reviewing local work.
- Git diff is not proof of target-org state; org comparison needs authorized retrieval.
- Review is read-only: no deploy, data change, Salesforce validation/dry-run, code edit, ADO/GitHub comment, PR approval, or merge.
- `validation-review.md` keeps handover evidence assessment; code review does not replace it.

## `code-review` overrides
- Spec source: the ADO WI read by the wrapper. Do not run `/setup-matt-pocock-skills`, do not search commit messages for `#123` GitHub issues, and do not ask for a spec when the WI was read.
- Fixed point: the diff base above. Do not ask the user for it.
- Standards sources: `.codex/knowledge/salesforce-review-standards.md` when the diff touches Salesforce code or metadata, plus repo docs the upstream skill finds. These documented standards override the upstream smell baseline.
- Sub-agents: run both axes in parallel fresh sub-agents when the agent supports them. Otherwise run Spec first, then Standards, judging each axis only against its own sources.
- Report the two axes under separate headings without merging or reranking, as upstream requires.

## `differential-review` overrides
- Trigger: only HIGH from the wrapper's risk classification: `salesforce-review-standards.md` for Salesforce, the upstream Risk Level Triggers listed in the wrapper for other systems. Otherwise report `Security: not triggered` with the level and reason.
- For Salesforce diffs, map upstream risk categories to the Salesforce HIGH list; skip patterns that only apply to smart contracts (reentrancy, `onlyOwner`, overflow in value-transfer contracts).
- The report file is the only allowed write: `~/codex_tmp/review/<WI or branch>/DIFFERENTIAL_REVIEW_REPORT.md`. Never write into the repository.
- `differential-review:adversarial-modeler`, `audit-context-building`, and `issue-writer` are not installed; read `adversarial.md` instead and skip those integrations.
- Time estimates in the upstream examples are not targets; scale depth to the risk level.

## Maintenance
Upstream sources, pinned commits, tree SHAs, and licenses are in `review-skill-sources.json` at the agent-kit repo root (not linked into project repos); read it only when installing, auditing, or updating review skills.
