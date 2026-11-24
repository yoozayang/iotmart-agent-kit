# Org access and technical references

- Before org operations, read `.codex/knowledge/environments.md` for exact alias case/identity and resolve Target Org; ask if absent, never substitute another org. Prod operations also read `.codex/playbooks/prod-validate.md`; querying does not authorize validation/dry-run.
- Retrieve comparisons to `~/codex_tmp` with `sf project retrieve start --target-metadata-dir ... --unzip`; remove/move accidental repo artifacts before handoff.
- Use context7 for external library/framework/SDK/API/CLI/cloud docs, versions, and syntax, not internal repo logic.

# Azure DevOps Wiki

- `azure-devops` MCP is defined in each agent's user-level config (Codex `~/.codex/config.toml`, Claude Code `~/.claude.json`, Gemini `~/.gemini/config/mcp_config.json`) with Azure CLI auth; never install, reconfigure, or start it during a task.
- Tools: `search_wiki`; `wiki` (`list_wikis`, `get_wiki`, `list_pages`, `get_page`, `get_page_content`); `wiki_upsert_page` (create/update); `core_list_projects`. No delete/move tool: ask the user.
- Tools absent: MCP loads only at session start; tell the user once to reload MCP or open a new session, then stop. Auth error: ask the user to run `az login`. Do not retry either.
- Update an existing page only after `get_page_content`: edit in place and pass its `etag`; never overwrite from a local draft.

# DevOps Tracker

- `devops-tracker` MCP connects to `https://iotmart-tracker.pages.dev/api/client/mcp` with each member's personal `WORKSPACE_CLIENT_TOKEN` (`Authorization: Bearer ${WORKSPACE_CLIENT_TOKEN}`), defined in `.codex/config.toml`, `.mcp.json`, `.gemini/settings.json`, or the user's own MCP config; never share or hardcode another person's token.
- Tools: `get_action_recap`, `get_daily_report_context`, `save_daily_report`, `get_work_item_detail`, `get_pr_detail`. Follow `.agents/skills/iotmart-work-recap/SKILL.md` for response format, sync-time disclosure, and confirmation before `save_daily_report`.
- Tools absent or 401/token-missing: tell the user once to create a personal `wsk_...` token at `https://iotmart-tracker.pages.dev` (My Work -> AI client), set `WORKSPACE_CLIENT_TOKEN`, add the remote MCP endpoint if needed, and reload MCP or open a new session; do not retry.
