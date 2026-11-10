# Task routing

- 先依本次操作選流程,再追加涉及系統的知識;多個明確操作可組合,不可僅因提到系統名稱載入其全部流程
- 知識不授權寫入;進入測試,文件寫入,WI更新,環境操作或部署前才載入該操作規則
- Review為唯讀模式:不疊加需求紀錄,Notion寫入,開發分支,部署或交付流程;另有明確操作要求時才切換並載入
- 路徑以kit/project根目錄為準;下列入口自行指向必要細節,不要預讀所有參考文件

## 操作入口
| 操作 | 必讀入口 |
| --- | --- |
| 只讀ADO WI | `.codex/playbooks/ado-work-item.md` |
| 需求釐清/落差分析 | `.codex/skills/requirement-review.md` |
| 實作前/設計變更 | `.codex/skills/minimum-sdd.md`;IoTMart WI開發加`.codex/playbooks/git-baseline.md` |
| Code review/PR/已實作WI | `.agents/skills/iotmart-code-review/SKILL.md` |
| 建立/切換開發branch,Git基準/PR範圍 | `.codex/playbooks/git-baseline.md` |
| 回寫WI開發交接 | `.codex/playbooks/wi-development-handoff.md` |
| 建立/更新Notion任務紀錄 | `.codex/skills/task-notion-record.md` |
| 任意Notion寫入 | `.agents/skills/evidence-investigation-documentation/references/content-preservation.md` |
| 調查repo/系統,整理維運文件 | `.agents/skills/evidence-investigation-documentation/SKILL.md` |
| 設計驗證案例 | `.codex/skills/test-case-generation.md` |
| 實作交付/檢查驗證證據 | `.codex/skills/validation-review.md`;缺少相關案例時加`.codex/skills/test-case-generation.md` |
| 準備部署交付/授權摘要 | `.codex/skills/deployment-package.md` |
| Salesforce query/retrieve/data/metadata/org操作 | `.codex/playbooks/mcp-usage.md`;用官方skill時先讀`.codex/playbooks/sf-skills-overlay.md`及對應`.agents/skills/platform-*/SKILL.md` |
| 寫SOQL/SOSL,編輯metadata XML,執行Apex test | `.codex/playbooks/sf-skills-overlay.md`及對應官方skill;標準欄位未驗證時加`platform-data-and-tooling-api-context-get`,metadata XML加`platform-metadata-api-context-get`;本地查閱不授權org操作 |
| Salesforce deploy/validation/dry-run | `.codex/playbooks/salesforce-deploy.md`;Prod加`.codex/playbooks/prod-validate.md`,Sandbox加`.codex/playbooks/uat-compare.md`;再載入前列org操作規則 |
| Prod內容比對 | `.codex/playbooks/prod-validate.md`,`.codex/playbooks/mcp-usage.md` |
| Dev/UAT/Sandbox內容比對 | `.codex/playbooks/uat-compare.md`,`.codex/playbooks/mcp-usage.md` |
| 查環境alias/Org Id/網址/登入,前台瀏覽器測試 | `.codex/knowledge/environments.md` |
| 通知收件人查詢或異動 | `.codex/playbooks/email-recipient-change.md`;異動才追加deploy流程 |
| Buzz協作平台事件 | `.agents/skills/buzz-collaboration/SKILL.md` |

## 系統知識與條件流程
| 涉及範圍 | 追加 |
| --- | --- |
| Salesforce/SFCC/Magnolia/UI/商品/價格/購物車/訂單 | `.codex/knowledge/market-architecture.md` |
| 跨系統整合/資料責任 | `.codex/knowledge/system-landscape.md` |
| SAP/SIS | `.codex/knowledge/sap-sis.md`,`.codex/knowledge/system-landscape.md` |
| Magnolia實作/Git/部署 | `.codex/playbooks/magnolia-flow.md`;純review不載入此操作流程 |
| 幣別新增或工項盤點 | `.codex/playbooks/currency-onboarding.md` |
| Salesforce review | `.codex/knowledge/salesforce-review-standards.md`;HIGH風險由review入口追加`differential-review` |

第三方skill不手改;衝突依`AGENTS.md`與對應overlay處理
