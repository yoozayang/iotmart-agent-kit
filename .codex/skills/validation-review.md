# Validation evidence

Before implementation handoff or a deployment-readiness claim:
- Compare requirements, changed scope, and confirmed SDD with executed checks/results.
- Report covered behavior, missing evidence, risks, and needed checks. Separate executed checks from recommendations; explain skipped tests and residual risk.
- Confirm validation and deployment scopes match. Relevant deployment playbooks govern Salesforce authorization and test levels.
- Browser-only E2E uses Prod unless specified otherwise and needs no additional verification approval. This exception does not authorize Salesforce CLI, data/metadata, deploy, validation, or dry-run.
