# Org access and technical references

- Before org operations, read `.codex/knowledge/environments.md` for exact alias case/identity and resolve Target Org; ask if absent, never substitute another org. Prod operations also read `.codex/playbooks/prod-validate.md`; querying does not authorize validation/dry-run.
- Retrieve comparisons to `~/codex_tmp` with `sf project retrieve start --target-metadata-dir ... --unzip`; remove/move accidental repo artifacts before handoff.
- Use context7 for external library/framework/SDK/API/CLI/cloud docs, versions, and syntax, not internal repo logic.
