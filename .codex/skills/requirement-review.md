# Requirement analysis

- Read the supplied requirement and relevant source; for ADO use `.codex/playbooks/ado-work-item.md`. Do not design/implement before identifying missing information and risks.
- Distinguish verified facts, evidence-backed inferences, and unknowns. Do not infer market, system owner, environment, or Target Org.
- Resolve answers available from WI/code/data with cited evidence; reserve pending questions for user/PM decisions.
- Record summary, current understanding, gaps, risks, and necessary questions. In chat show differences between WI, earlier work, and verified environment state, then user decisions and PM questions; do not repeat known background or recorded detail.
- Explain PM questions with the premise/current state and recommendation rationale. Expand platform terms when asked; distinguish custom from native objects/fields.
- Handoff only confirmed scope for implementation. Keep unresolved decisions separate and specify how the developer should handle them.
- Write Notion only when authorized, using `.codex/skills/task-notion-record.md`; analysis alone does not load writing rules. The current specification excludes struck-through history.
- Notion access: prefer connected tools; API fallback may use the configured `NOTION_API_KEY` without exposing it.
