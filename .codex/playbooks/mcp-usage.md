# Org access and technical references

- Before org operations, read `.codex/knowledge/environments.md` for exact alias case/identity and resolve Target Org; ask if absent, never substitute another org. Prod operations also read `.codex/playbooks/prod-validate.md`; querying does not authorize validation/dry-run.
- Retrieve comparisons to `~/codex_tmp` with `sf project retrieve start --target-metadata-dir ... --unzip`; remove/move accidental repo artifacts before handoff.
- Use context7 for external library/framework/SDK/API/CLI/cloud docs, versions, and syntax, not internal repo logic.

# Azure DevOps Wiki

- `azure-devops` MCP is defined in this kit (`.codex/config.toml`, `.mcp.json`) with Azure CLI auth; never install, reconfigure, or start it during a task.
- Tools: `search_wiki`; `wiki` (`list_wikis`, `get_wiki`, `list_pages`, `get_page`, `get_page_content`); `wiki_upsert_page` (create/update); `core_list_projects`. No delete/move tool: ask the user.
- Tools absent: MCP loads only at session start; tell the user once to reload MCP or open a new session, then stop. Auth error: ask the user to run `az login`. Do not retry either.
- Update an existing page only after `get_page_content`: edit in place and pass its `etag`; never overwrite from a local draft.
