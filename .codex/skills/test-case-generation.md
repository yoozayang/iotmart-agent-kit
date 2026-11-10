# Validation cases

- Derive cases from requirements, confirmed SDD, affected code, and market/platform context.
- Cover applicable positive, negative, edge, and regression behavior; omit unrelated systems/cases.
- State scenario, expected result, and verification method. Do not add unrelated tests to compensate for others' failures.
- Salesforce execution/test levels follow the routed deployment/test playbooks; `NoTestRun` is allowed only where those playbooks permit it. Prod tests must match the confirmed metadata scope.
