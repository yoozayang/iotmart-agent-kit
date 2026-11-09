# Code Review Overlay

This is the IoTMart-specific override for third-party review skills. `AGENTS.md` and task-specific playbooks take precedence. Keep upstream skill files unmodified.

## Baseline and evidence
- ADO task description and acceptance criteria are the requirement baseline when provided; do not substitute branch name, PR prose, or inferred intent.
- For IoTMart branch diff use `origin/Dev...HEAD` unless explicitly instructed otherwise. Inspect merge-base and uncommitted changes. For personal repos follow their own default branch.
- An org comparison requires actual target-org files and authorized retrieval; Git diff is not proof of deployed org differences.
- Read-only review is default. No silent deploy, data modification, Salesforce validation/dry-run, PR approval, or merge.
- Keep existing `validation-review.md` for handover evidence assessment; code review does not replace it.

## Upstream skill routing and provenance
| Skill | Source repository | Upstream path | Role |
| --- | --- | --- | --- |
| code-review-and-quality | https://github.com/addyosmani/agent-skills | skills/code-review-and-quality/ | Primary five-axis review |
| differential-review | https://github.com/trailofbits/skills | plugins/differential-review/skills/differential-review/ | Security-sensitive change analysis |
| requesting-code-review | https://github.com/obra/superpowers | skills/requesting-code-review/ | Optional reviewer delegation |

These are upstream references, not claims that the skills are already installed. For any vendored copy, record source repository, exact upstream path, commit SHA, license, content hash, and local changes in `review-skill-sources.json` and `THIRD_PARTY_NOTICES.md`. Do not edit upstream files in place. Update from upstream by re-importing a pinned revision and comparing changes; rebase is optional, not required. Update the local overlay separately. Never claim automatic updates unless the workflow actually covers the new skill.
