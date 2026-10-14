# Test Case Generation Skill

## Purpose
- Help the agent generate validation scenarios from Task,Spec,and SDD
- Produce focused test coverage for positive,negative,edge,regression,and platform-specific behavior

## When To Use
- Before handover
- Before or after implementation when validation scenarios are needed
- When preparing Apex tests,manual QA cases,or deployment validation notes

## Required Inputs
- User task
- Minimum Spec if available
- Minimum SDD if available
- Changed files or planned changed files
- Relevant platform knowledge/playbooks

## Expected Outputs
- Positive Test Cases
- Negative Test Cases
- Edge Cases
- Regression Cases
- Platform-Specific Checks

## Guardrails
- Tests must align with the actual impacted platform and market
- Do not add unrelated tests just to compensate for unrelated coverage issues
- Sandbox test issues caused by others may use`NoTestRun`only when allowed by the relevant playbook and task context
- Prod test strategy must be confirmed and use the same metadata scope as validation/deploy
- Include Salesforce,SFCC,Magnolia,or integration-specific checks only when the routed files indicate they are relevant
