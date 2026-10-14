# Codex Routing

## 目的
- 本檔是task-type routing table
- 先套用`AGENTS.md`的Ponytail-first evaluation與硬限制
- 再依本檔選擇要讀的knowledge,playbook,skill
- 若任務同時符合多個類型,全部讀取
- 若規則重複,以正式基準位置為主,重複位置保留reference,不可立即刪除

## Layer Definition
- `AGENTS.md`:
  - Root control layer
  - Mandatory entry rules,hard constraints,Ponytail-first requirement,routing entry points
- `.codex/knowledge/*.md`:
  - Stable background knowledge,architecture,system responsibility boundaries,domain context
- `.codex/playbooks/*.md`:
  - Executable operational procedures,deployment steps,validation steps,compare flow,environment-specific workflows
- `.codex/skills/*.md`:
  - Reusable AI/coding-agent work patterns that produce structured outputs
- `.agents/skills/*/SKILL.md`:
  - Installed agent skills,own and third-party
  - Third-party official skills stay unmodified,repo overrides live in`.codex/playbooks/sf-skills-overlay.md`

## Task Routing Table
| Task type | Required files |
| --- | --- |
| Requirement unclear | `.codex/skills/requirement-review.md`,`.codex/skills/minimum-spec.md` |
| Before implementation | `.codex/skills/minimum-sdd.md` |
| During implementation | Relevant knowledge/playbook from this table,plus`.codex/skills/minimum-sdd.md` |
| Before handover | `.codex/skills/test-case-generation.md`,`.codex/skills/validation-review.md` |
| Before deployment task creation | `.codex/skills/deployment-package.md`,relevant deployment playbook |
| Magnolia task | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/magnolia-flow.md` |
| Salesforce/SFCC task | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/salesforce-deploy.md`,`.codex/playbooks/sf-skills-overlay.md` |
| Cross-platform task | `.codex/knowledge/system-landscape.md`,`.codex/knowledge/market-architecture.md`,related playbooks,`.codex/skills/deployment-package.md` |
| Prod validation | `.codex/playbooks/prod-validate.md`,`.codex/playbooks/sf-skills-overlay.md` |
| Prod compare | `.codex/playbooks/prod-validate.md`,`.codex/playbooks/mcp-usage.md` |
| Dev/UAT compare | `.codex/playbooks/uat-compare.md` |
| Sandbox deploy scope | `.codex/playbooks/uat-compare.md`,`.codex/playbooks/salesforce-deploy.md` |
| Data/Metadata/MCP task | `.codex/playbooks/mcp-usage.md`,`.codex/playbooks/sf-skills-overlay.md` |
| Investigation,repository/system discovery,or task documentation | `.agents/skills/evidence-investigation-documentation/SKILL.md` |
| Git baseline,branch diff,PR scope | `.codex/playbooks/git-baseline.md` |
| SAP/SIS task | `.codex/knowledge/sap-sis.md`,`.codex/knowledge/system-landscape.md` |
| Product/pricing/cart/order | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/salesforce-deploy.md` |
| UI/template/content | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/magnolia-flow.md` |
| Salesforce official skill usage(retrieve,deploy,SOQL,metadata XML,Apex test) | `.codex/playbooks/sf-skills-overlay.md`,then matching`.agents/skills/platform-*/SKILL.md` |

## 正式基準位置
| Rule/content block | 正式基準位置 | Preserved references |
| --- | --- | --- |
| Ponytail-first evaluation | `AGENTS.md` | None |
| Repo paths,project positioning,temp output,PR summary reminder | `.codex/knowledge/repo-map.md` | `AGENTS.md`references summary/temp only |
| Market architecture and issue ownership | `.codex/knowledge/market-architecture.md` | `AGENTS.md`,this routing file |
| Cross-system landscape and responsibility boundaries | `.codex/knowledge/system-landscape.md` | `market-architecture.md`,this routing file |
| SAP/SIS responsibility flow | `.codex/knowledge/sap-sis.md` | `system-landscape.md`,this routing file |
| Git baseline rules | `.codex/playbooks/git-baseline.md` | `AGENTS.md`hard limits |
| MCP/Data/Metadata rules | `.codex/playbooks/mcp-usage.md` | `AGENTS.md`hard limits |
| Salesforce deploy rules | `.codex/playbooks/salesforce-deploy.md` | `AGENTS.md`hard limits |
| Magnolia flow | `.codex/playbooks/magnolia-flow.md` | `AGENTS.md`,this routing file |
| Dev/UAT/Sandbox compare | `.codex/playbooks/uat-compare.md` | `AGENTS.md`,this routing file |
| Prod validation and Quick Deploy | `.codex/playbooks/prod-validate.md` | `AGENTS.md`,this routing file |
| Requirement review workflow | `.codex/skills/requirement-review.md` | `AGENTS.md`,this routing file |
| Minimum spec workflow | `.codex/skills/minimum-spec.md` | `AGENTS.md`,this routing file |
| Minimum SDD workflow | `.codex/skills/minimum-sdd.md` | `AGENTS.md`,this routing file |
| Test case generation workflow | `.codex/skills/test-case-generation.md` | `AGENTS.md`,this routing file |
| Validation review workflow | `.codex/skills/validation-review.md` | `AGENTS.md`,this routing file |
| Deployment package workflow | `.codex/skills/deployment-package.md` | `AGENTS.md`,this routing file |
| Evidence investigation and documentation workflow | `.agents/skills/evidence-investigation-documentation/SKILL.md` | `AGENTS.md`,this routing file |
| Official sf-skills overrides and SOQL/metadata supplementary rules | `.codex/playbooks/sf-skills-overlay.md` | `AGENTS.md`,this routing file |

## Needs Human Review
- Salesforce EN/NA environment is preserved from both sources:
  - Original repo AGENTS.md listed `EN/NA:NQA+Prod`
  - Split zip playbook listed:
```text
EN/NA:
  - Dev:`NQA'
```
- Do not delete either reference until the intended EN/NA environment wording is confirmed
