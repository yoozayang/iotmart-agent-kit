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

## Task Routing Table
| Task type | Required files |
| --- | --- |
| Requirement unclear | `.codex/skills/requirement-review.md`,`.codex/skills/minimum-spec.md` |
| Before implementation | `.codex/skills/minimum-sdd.md` |
| During implementation | Relevant knowledge/playbook from this table,plus`.codex/skills/minimum-sdd.md` |
| Before handover | `.codex/skills/test-case-generation.md`,`.codex/skills/validation-review.md` |
| Before deployment task creation | `.codex/skills/deployment-package.md`,relevant deployment playbook |
| Magnolia task | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/magnolia-flow.md` |
| Salesforce/SFCC task | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/salesforce-deploy.md` |
| Cross-platform task | `.codex/knowledge/system-landscape.md`,`.codex/knowledge/market-architecture.md`,related playbooks,`.codex/skills/deployment-package.md` |
| Prod validation | `.codex/playbooks/prod-validate.md` |
| Prod compare | `.codex/playbooks/prod-validate.md`,`.codex/playbooks/mcp-usage.md` |
| Dev/UAT compare | `.codex/playbooks/uat-compare.md` |
| Sandbox deploy scope | `.codex/playbooks/uat-compare.md`,`.codex/playbooks/salesforce-deploy.md` |
| Data/Metadata/MCP task | `.codex/playbooks/mcp-usage.md` |
| Investigation,repository/system discovery,or task documentation | `/Users/yoozayang/.agents/skills/evidence-investigation-documentation/SKILL.md` |
| Git baseline,branch diff,PR scope | `.codex/playbooks/git-baseline.md` |
| SAP/SIS task | `.codex/knowledge/sap-sis.md`,`.codex/knowledge/system-landscape.md` |
| Product/pricing/cart/order | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/salesforce-deploy.md` |
| UI/template/content | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/magnolia-flow.md` |
| Apex implementation / refactor | `.codex/knowledge/market-architecture.md`,`.agents/skills/sf-apex-engine/SKILL.md` |
| Code review / Performance scan | `.agents/skills/sf-quality-gate/SKILL.md`,`.codex/skills/validation-review.md` |
| Apex test execution / generation | `.agents/skills/sf-apex-engine/SKILL.md`,`.codex/skills/test-case-generation.md` |
| Metadata change (Field, PermSet, Flow) | `.agents/skills/sf-metadata-architect/SKILL.md` |
| Org data inquiry / Log debug | `.agents/skills/sf-data-explorer/SKILL.md`,`.codex/playbooks/mcp-usage.md` |
| Deployment preparation | `.agents/skills/sf-deploy-guard/SKILL.md`,`.codex/skills/deployment-package.md`,`.codex/playbooks/salesforce-deploy.md` |
| Prod validation preparation | `.agents/skills/sf-deploy-guard/SKILL.md`,`.codex/playbooks/prod-validate.md` |

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
| Evidence investigation and documentation workflow | `/Users/yoozayang/.agents/skills/evidence-investigation-documentation/SKILL.md` | `AGENTS.md`,this routing file |
| Salesforce quality gate | `.agents/skills/sf-quality-gate/SKILL.md` | `AGENTS.md`,this routing file |
| Salesforce Apex engine | `.agents/skills/sf-apex-engine/SKILL.md` | `AGENTS.md`,this routing file |
| Salesforce metadata architect | `.agents/skills/sf-metadata-architect/SKILL.md` | `AGENTS.md`,this routing file |
| Salesforce data explorer | `.agents/skills/sf-data-explorer/SKILL.md` | `AGENTS.md`,this routing file |
| Salesforce deploy guard | `.agents/skills/sf-deploy-guard/SKILL.md` | `AGENTS.md`,this routing file |

## Needs Human Review
- Salesforce EN/NA environment is preserved from both sources:
  - Original repo AGENTS.md listed `EN/NA:NQA+Prod`
  - Split zip playbook listed:
```text
EN/NA:
  - Dev:`NQA'
```
- Do not delete either reference until the intended EN/NA environment wording is confirmed
