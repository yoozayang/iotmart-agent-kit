# Minimum Spec Skill

## Purpose
- Help the agent produce a lightweight Minimum Spec after requirement clarification
- Convert clarified requirements into a small implementation-ready scope without adding unnecessary abstraction, friendly for both human and coding agent

## When To Use
- Requirement has been reviewed but a compact spec is needed before implementation
- User asks for expected behavior,scope,or validation approach
- Task is small enough that a full SDD would be excessive but still needs traceable decisions

## Required Inputs
- Requirement Summary
- Current Understanding
- Clarified answers or accepted assumptions
- Relevant knowledge/playbook files selected by`.codex/routing.md`
- Existing affected files or components if known

## Expected Outputs
- Impacted Areas
- Expected Behavior
- Validation Approach
- Open Questions

## Guardrails
- Keep the spec minimal and directly tied to the user request
- Do not collapse multiple rules into vague summaries
- Keep unresolved assumptions visible under Open Questions
- For SFCC codes, do not use`origin/main`as default baseline in this repo
- For Magnolia codes, use `origin/main` derived function branch (usually *_A) branch, check with user first
- For UAT/Sandbox scope,use`origin/Dev...HEAD`only to identify current development files,not to judge org correctness
