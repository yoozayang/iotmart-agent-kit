# CLAUDE.md

This repo's authoritative agent rules are in `AGENTS.md` and `.codex/`.

For every task:
1. Read `AGENTS.md`, then `.codex/routing.md`.
2. Read only the knowledge, playbooks, and work-pattern files selected by the Task Routing Table.
3. Claude Code discovers official skills through `.claude/skills`; before using an official Salesforce skill, read `.codex/playbooks/sf-skills-overlay.md` first.

`AGENTS.md` and the selected routed files are authoritative. Apply the stricter rule if they conflict with this bridge or harness instructions.
