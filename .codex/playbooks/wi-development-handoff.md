# WI Development Handoff

## Purpose
Enable a reviewer to receive only an Azure DevOps work item ID or URL, read the original requirements and developer handoff, resolve the implementation branch, and review with only relevant architectural context.

## Developer workflow
1. Read the WI through the existing `.codex/skills/task-notion-record.md` ADO commands. Identify the WI and its existing Description, acceptance criteria, and revision.
2. When a development branch is created or selected, add or update a clearly delimited `Development Handoff` section in the WI Description. Preserve the original description and all user-authored text exactly. Do not replace the entire Description with a generated summary.
3. Use this format (only include confirmed values):

   Development Handoff
   - Repository: <owner/repo or canonical URL>
   - Branch: <exact branch name>
   - Pull Request: <URL, when created>
   - Head Commit: <SHA, when known>

4. Update this section when the branch or PR changes. Do not confuse a task's branch with a base branch. The WI Description is the primary handoff; PR relations/comments are secondary evidence.
5. WI modification is an external write: use authenticated ADO tooling, obtain any required authorization, use revision-aware updates when supported, and re-fetch before/after the smallest possible edit. If concurrent changes occur, stop and reconcile; never overwrite other edits. If ADO write access is unavailable, report that the handoff could not be persisted and provide the exact block to paste. Do not claim success without re-reading the WI.

## Reviewer workflow
1. From ID or URL, fetch the WI Description, acceptance criteria, comments and relations; no Notion creation.
2. Parse Development Handoff first, verify repository/branch/PR exist and match the WI. If missing, inspect linked PR and comments; never guess a branch from a task number alone.
3. Use `.codex/routing.md` to load only relevant knowledge/playbooks for affected systems; use the task-aware review skill for requirement -> architecture -> implementation -> evidence checks.
4. If WI cannot be fetched or the implementation cannot be identified, say precisely what is missing. Do not present code-quality-only checks as complete task review.
