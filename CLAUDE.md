# CLAUDE.md

This repo already has a layered coding-agent rule system, originally written for
Codex, at root `AGENTS.md` and `.codex/`. Treat it as authoritative for this repo,
in addition to whatever the harness system prompt provides.

## Load order for every task
1. `AGENTS.md` — root hard constraints and routing entry, read first
2. `.codex/routing.md` — task-type table: which knowledge/playbook/skill files apply
3. `.codex/knowledge/*.md` — stable background (repo-map, market-architecture,
   system-landscape, sap-sis)
4. `.codex/playbooks/*.md` — executable procedures (git-baseline, mcp-usage,
   salesforce-deploy, magnolia-flow, uat-compare, prod-validate, sf-skills-overlay)
5. `.codex/skills/*.md` — work-pattern templates (requirement-review, minimum-spec,
   minimum-sdd, test-case-generation, validation-review, deployment-package). These
   aren't registered as Claude Code skills — just Read the relevant file at that
   phase of work (before clarifying a requirement, before implementation, before
   handover, before packaging a deployment).
6. `.agents/skills/evidence-investigation-documentation/SKILL.md` —
   shared investigation and documentation workflow. Read it whenever asked to
   investigate, map, document, or turn a completed task into documentation.
7. `.agents/skills/platform-*/SKILL.md` — official `forcedotcom/sf-skills`, kept
   unmodified and exposed as Claude Code skills through `.claude/skills`. Before
   using any of them, read `.codex/playbooks/sf-skills-overlay.md`; the overlay
   wins wherever it conflicts with the official skill (e.g. their
   `--source-dir force-app` deploy examples and `--ignore-conflicts` are forbidden here).

If `AGENTS.md`/`.codex` content ever conflicts with this file, apply the stricter,
more conservative rule — same policy the source system uses internally.

## Hard constraints (do not weaken or bypass)
- No unauthorized Prod deploy. No deploy/validate/dry-run command without explicit
  user authorization AND a confirmed Target Org.
- Before any environment comparison: the comparison target is always the actual
  files retrieved from that target environment — never treat a branch diff as an
  environment diff.
- Metadata: retrieve before modifying; never blind-overwrite org content.
- Deploy only changed files via `-m` / `-x package.xml`. Never full deploy, never
  `--source-dir force-app`.
- Salesforce CLI: `sf` only, never `sfdx`.
- Prod deploy method: `Validate Only` then tell the user to do the manual Quick
  Deploy from Deployment Status (with the URL) — never Quick Deploy it yourself.
- Git baseline: default relative-diff comparison is `origin/Dev...HEAD`, not
  `origin/main`, unless the user explicitly says otherwise for this repo.
- Branch naming: `<username>/feature/*`, `<username>/bugfix/*`.
- Sandbox: never overwrite someone else's changes — integrate them, or stop and ask
  if the conflict is unclear.
- Commits/PRs follow `GIT_GUIDE.md`.

## Market/system quick reference
- EN/NA: pure SFCC / B2B Commerce.
- EU: Magnolia (FE/template/content/render) + SFCC (product/pricing/cart/checkout/order).
- KR/JP: EU model extended, usually only diverging on currency/payment method.
- Cross-system responsibility boundaries (SAP/PIS/APIM/Event Mesh/Payment/Shipment):
  see `.codex/knowledge/system-landscape.md` before assuming ownership.
