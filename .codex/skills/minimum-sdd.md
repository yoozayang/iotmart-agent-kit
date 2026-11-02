# Minimum SDD Skill

## Purpose
- Help the agent produce a Minimum SDD before implementation
- State what will change,where it will change,expected behavior,validation,and risks

## When To Use
- Before implementation
- During implementation when the task needs a lightweight design anchor
- When multiple systems,metadata types,or deployment constraints are involved

## Required Inputs
- Requirement Summary or Minimum Spec
- Relevant routing decision from`.codex/routing.md`
- Relevant knowledge/playbook files
- Current code or metadata inspection results
- Known constraints from`AGENTS.md`
- Read user specified task page (e.g. Azure with task number or url) 

## Expected Outputs
- Change Summary
- Impacted Areas
- Expected Behavior
- Validation Approach
- Open Questions / Risks

## Guardrails
- Start from existing code and platform capabilities before proposing new files or abstractions
- Keep the SDD scoped to the requested change
- Do not proceed to deploy,validation,or dry-run commands without explicit authorization
- For Metadata changes,retrieve before modifying and never overwrite org content blindly
- If implementation becomes unnecessary after Ponytail-first evaluation,state the no-code path instead
