# Codex Routing

## 目的
- 本檔是task-type routing table
- 先套用`AGENTS.md`的Ponytail-first evaluation與硬限制
- 再依本檔選擇要讀的knowledge,playbook,skill
- 若任務同時符合多個類型,全部讀取

## Layer Definition
- `AGENTS.md`:全域硬限制,Ponytail-first與routing entry
- `.codex/knowledge/*.md`:穩定背景,架構與系統責任邊界
- `.codex/playbooks/*.md`:可執行流程與環境操作
- `.codex/skills/*.md`與`.agents/skills/*/SKILL.md`:按需工作模式與agent skills;官方skill原樣保留,repo覆寫在`.codex/playbooks/sf-skills-overlay.md`

## Task Routing Table
| Task type | Required files |
| --- | --- |
| Requirement unclear | `.codex/skills/requirement-review.md`,`.codex/skills/minimum-spec.md` |
| Read an Azure DevOps work item,create a task record,or update a task record in Notion | `.codex/skills/task-notion-record.md`,`.codex/skills/requirement-review.md` |
| Before implementation | `.codex/skills/minimum-sdd.md` |
| During implementation | Relevant knowledge/playbook from this table,plus`.codex/skills/minimum-sdd.md` |
| Before handover | `.codex/skills/test-case-generation.md`,`.codex/skills/validation-review.md` |
| Before deployment task creation | `.codex/skills/deployment-package.md`,relevant deployment playbook |
| Magnolia task | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/magnolia-flow.md` |
| Salesforce/SFCC task | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/salesforce-deploy.md`,`.codex/playbooks/sf-skills-overlay.md` |
| Cross-platform task | `.codex/knowledge/system-landscape.md`,`.codex/knowledge/market-architecture.md`,related playbooks,`.codex/skills/deployment-package.md` |
| Prod validation | `.codex/playbooks/prod-validate.md`,`.codex/playbooks/sf-skills-overlay.md`,`.codex/knowledge/environments.md` |
| Prod compare | `.codex/playbooks/prod-validate.md`,`.codex/playbooks/mcp-usage.md`,`.codex/knowledge/environments.md` |
| Dev/UAT compare | `.codex/playbooks/uat-compare.md`,`.codex/knowledge/environments.md` |
| UAT/Prod前台測試(Playwright,瀏覽器驗證),或需確認org alias,Org Id,前台網址,登入方式 | `.codex/knowledge/environments.md` |
| Sandbox deploy scope | `.codex/playbooks/uat-compare.md`,`.codex/playbooks/salesforce-deploy.md` |
| Data/Metadata/MCP task | `.codex/playbooks/mcp-usage.md`,`.codex/playbooks/sf-skills-overlay.md`,`.codex/knowledge/environments.md` |
| Investigation,repository/system discovery,or task documentation | `.agents/skills/evidence-investigation-documentation/SKILL.md` |
| Git baseline,branch diff,PR scope | `.codex/playbooks/git-baseline.md` |
| Email通知收件人查詢或異動 | `.codex/playbooks/email-recipient-change.md`,`.codex/playbooks/prod-validate.md`,`.codex/playbooks/sf-skills-overlay.md`,`.codex/knowledge/environments.md` |
| SAP/SIS task | `.codex/knowledge/sap-sis.md`,`.codex/knowledge/system-landscape.md` |
| Product/pricing/cart/order | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/salesforce-deploy.md` |
| UI/template/content | `.codex/knowledge/market-architecture.md`,`.codex/playbooks/magnolia-flow.md` |
| Salesforce official skill usage(retrieve,deploy,SOQL,metadata XML,Apex test) | `.codex/playbooks/sf-skills-overlay.md`,then matching`.agents/skills/platform-*/SKILL.md` |
| Multi-agent platform collaboration (Buzz, Nostr) | `.agents/skills/buzz-collaboration/SKILL.md` |

## 正式基準
- 全域硬限制與Ponytail-first以`AGENTS.md`為準
- 任務載入以Task Routing Table為準,各文件本文是其主題的正式程序或知識
- 官方skill保持原樣,與repo規則衝突或官方未涵蓋的補強以`.codex/playbooks/sf-skills-overlay.md`為準
