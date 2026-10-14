# Validation Review Skill

## Purpose
- Help the agent review whether validation evidence is sufficient
- Identify missing test evidence,risk areas,and additional checks before handover or deployment task creation

## When To Use
- Before handover
- After tests,manual checks,or validation commands have produced evidence
- When deciding whether the current evidence supports deployment readiness

## Required Inputs
- Change Summary
- Test results or manual validation evidence
- Changed files or deployment scope
- Relevant Minimum Spec or Minimum SDD
- Relevant deployment or compare playbook

## Expected Outputs
- Validation Coverage
- Missing Test Evidence
- Risk Areas
- Recommended Additional Checks

## Guardrails
- Do not claim validation is complete without evidence
- Separate executed checks from recommended checks
- If tests were not run,explain why and list residual risk
- E2E前端測試只操作網站前端時，不需另行取得驗證授權，預設使用正式網站，除非使用者明確指定其他環境
- 前述例外不涵蓋Salesforce CLI、Data、Metadata、deploy、validation或dry-run操作
- Prod validation or dry-run evidence must come from authorized commands against confirmed Target Org
- Confirm validation scope matches deployment scope
