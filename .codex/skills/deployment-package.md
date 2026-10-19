# Deployment Package Skill

## Purpose
- Help the agent prepare deployment-ready handover information
- Package change summary,test evidence,references,platform impacts,dependencies,sequence,and known risks

## When To Use
- Before deployment task creation
- Before requesting validation authorization
- When preparing handover for Salesforce,SFCC,Magnolia,or cross-platform deployment

## Required Inputs
- Change Summary
- Changed file list or metadata list
- Test evidence and validation review
- Relevant deployment playbook
- Target environment and Target Org when applicable
- Known dependencies and sequencing constraints

## Expected Outputs
- Change Summary
- Test Evidence
- Deployment References
- Platform Impacts
- Deployment Dependencies / Sequence
- Known Risks / Limitations

## Guardrails
- Do not execute deploy,validation,or dry-run commands from this skill
- Deployment package must preserve the same scope intended for validation and deployment
- Prod deployment must remain`Validate Only + manual Quick Deploy`,except standalone software declared by the user(see`.codex/playbooks/prod-validate.md`獨立軟體例外)
- UAT或其他非正式環境結果只可作為測試證據,不可決定、增減或替代Prod最終範圍;Prod範圍只以Prod實際retrieve比對結果定案
- For UAT/Sandbox,final deployment scope must trace back to`origin/Dev...HEAD`development file list or explicitly noted dependencies
- If dependencies are unclear,list them as risks rather than expanding deployment scope silently
