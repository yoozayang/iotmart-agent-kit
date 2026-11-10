# Deployment handoff

Before deployment-task creation or a validation-authorization request:
- Collect changed files/metadata, test evidence, dependencies, sequence, target environment/org, and relevant deployment procedures.
- Report: change summary, test evidence, references, platform impact, dependencies/order, and risks/limits. Preparing this handoff does not execute deploy/validation/dry-run.
- Preserve the intended validation/deploy scope. Prod scope comes from actual Prod retrieval, not UAT results; Sandbox scope traces to `origin/Dev...HEAD` or named necessary dependencies.
- Unclear dependencies are risks, not permission to expand scope. Prod authorization and independent-software exceptions remain in `.codex/playbooks/prod-validate.md`; load it before the corresponding operation.
