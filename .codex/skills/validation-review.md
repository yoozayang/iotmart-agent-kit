# Validation cases and evidence

When designing validation, before implementation handoff, or before a deployment-readiness claim:
- Derive scenarios from requirements, confirmed SDD, affected code, and market/platform context. Check applicable positive, negative, edge, and regression coverage even when tests already exist; test-class existence alone is not coverage evidence.
- State each needed scenario, expected result, and verification method. Add tests only for uncovered relevant behavior; do not compensate for unrelated failures or load unrelated systems.
- Compare requirements, changed scope, and confirmed SDD with executed checks/results.
- Report covered behavior, missing evidence, risks, and needed checks. Separate executed checks from recommendations; explain skipped tests and residual risk.
- Confirm validation and deployment scopes match. Relevant deployment playbooks govern Salesforce authorization and test levels.
- `NoTestRun` is allowed only where those playbooks permit it; Prod tests must match the confirmed metadata scope.
- Browser-only E2E uses Prod unless specified otherwise and needs no additional verification approval. This exception does not authorize Salesforce CLI, data/metadata, deploy, validation, or dry-run.
