# WI development handoff

For an authorized WI Description update:
1. Read `.codex/playbooks/ado-work-item.md`, then fetch the current Description, acceptance criteria, and revision.
2. Add/update only the delimited `Development Handoff` section; preserve all original requirement and user text exactly.

```text
Development Handoff
- Repository: <canonical URL>
- Branch: <exact development branch>
- Pull Request: <URL, when created>
- Head Commit: <SHA, when known>
```

3. Include only confirmed values; update when branch/PR changes. A base branch is not the implementation branch. Description is the primary handoff; PR relations/comments are fallback evidence.
4. Use authenticated ADO tooling and required write authorization. Re-fetch before/after, use revision-aware updates when supported, and stop on concurrent changes. If writing is unavailable, report it and provide the exact block to paste; do not claim persistence without read-back.
