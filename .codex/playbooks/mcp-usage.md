# Org access and technical references

- Target Org/explicit `-o`/authorization follow `AGENTS.md`. Before org operations read `.codex/knowledge/environments.md` for exact alias case/identity and resolve the specified target; ask if absent. Do not substitute another org or re-confirm an already specified target.
- Salesforce MCP acts only on configured `SF_TARGET_ORG`: use it only when matching the conversation's Target Org; otherwise use `sf` CLI.
- Query/retrieve/metadata/test details come from the corresponding official skill under `.codex/playbooks/sf-skills-overlay.md`. Prod operations also load `.codex/playbooks/prod-validate.md`; query is not validation/dry-run authorization.
- Use context7 for library/framework/SDK/API/CLI/cloud documentation, versions, and syntax, not internal repository process or business inference.
- Temporary query/retrieve/research output follows the root `~/codex_tmp` rule. Compare retrieval uses `--target-metadata-dir ... --unzip`; remove/move accidental repo artifacts before handoff.
- Notion writing is a separate operation in `.codex/routing.md`; org access does not load Notion creation/update rules.
