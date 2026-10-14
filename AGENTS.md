# Codex專案規範

## 第一必要步驟:Ponytail-first evaluation
- 每次任務的第一步必須先做Ponytail-first evaluation
- 這是執行流程優先序,不是宣稱改變Codex平台實際instruction載入順序
- 若Ponytail plugin或skill可用,先執行Ponytail評估,再依本檔與既有repo規則實作
- 評估清單:
  - 能否不改程式碼解決
  - 能否重用既有程式碼
  - 能否用既有平台原生功能解決
  - 能否用標準函式庫或已安裝依賴解決
  - 能否減少修改檔案數
  - 能否縮小diff
  - 能否避免新增抽象層
  - 能否避免新增檔案
  - 能否避免新增service或架構層

## 根控制定位
- 本檔是Codex與coding agent的top-level control entry
- 本檔只保留mandatory entry rules,hard constraints,Ponytail-first requirement,routing entry points
- 詳細背景知識讀`.codex/knowledge/*.md`
- 詳細執行流程讀`.codex/playbooks/*.md`
- 可重用AI/coding-agent工作模式讀`.codex/skills/*.md`
- 任務路由先讀`.codex/routing.md`
- 若本檔與子文件衝突,採用更嚴格且更保守的規則
- 若不確定規則歸屬,保留原規則並增加reference,不可刪除或弱化

## 取用順序
1. 先做Ponytail評估
2. 再套用本`AGENTS.md`的硬限制
3. 讀`.codex/routing.md`
4. 依題目載入對應`knowledge`,`playbooks`,`skills`
5. 再產出最小可行實作方案
6. 仍有必要時才改碼
7. 完成後做Ponytail review

## Repo硬限制
- security/compliance/data integrity/permissions/deployment requirements仍由本repo規範主導
- 絕對禁止未授權Prod deploy
- 未取得使用者明確授權前,禁止執行任何deploy、validation、dry-run命令
- 任何validation或dry-run也必須先取得使用者明確授權並確認Target Org
- 檔案比對前:
  - 比較對象一律是對象環境實際檔案
  - 禁止以branch差異直接視為對象環境差異
- Metadata:
  - 先retrieve再修改
- Sandbox:
  - 禁止覆蓋他人修改，以保留org既有開發，與整合本地開發為原則
  - 衝突不明時停止整合，並討論
- Data/Metadata前:
  - 確認Target Org
- `SF_TARGET_ORG`不符:
  - 主動提醒

## Deploy硬限制
- 僅deploy差異檔
- 禁止:
  - 全量deploy
  - `--source-dir force-app`
- 使用:
  - `-m`
  - `-x package.xml`
- 修改後:
  - DRY檢查
  - Apex test
- Salesforce CLI:
  - 僅`sf`
  - 不使用`sfdx`
- Prod正式環境部署方式:
  - 一律`Validate Only + manual Quick Deploy`
  - validation成功後提示使用者於Deployment Status手動Quick Deploy，並提供網址
- 執行層防護:
  - `sf`經`bin/sf` guard執行，Codex rules與Claude permissions另行要求確認，詳見`.codex/playbooks/sf-skills-overlay.md`
  - 被guard阻擋時停止並回報使用者，禁止以`SF_GUARD_BYPASS`、真實`sf`絕對路徑、MCP或其他方式繞過

## Git基準硬限制
- branch:
  - `feature/*`
  - `bugfix/*`
- 相對差異/新增/回歸判斷:
  - 預設以`origin/Dev`為比較基準
  - 非使用者明確指定時,禁止以`origin/main`作為此repo的預設相對基準
  - 回覆中若提到「這次分支新增/這次修改/相對差異」,都應先以`origin/Dev...HEAD`確認
- Commit/PR:
  - 遵循`GIT_GUIDE.md`
- 大量非功能diff:
  - 優先檢查base branch

## 問題分流入口
- Requirement unclear:
  - 先讀`.codex/skills/requirement-review.md`
  - 再讀`.codex/skills/minimum-spec.md`
- Before implementation:
  - 先讀`.codex/skills/minimum-sdd.md`
- During implementation:
  - 讀`.codex/routing.md`指定的knowledge/playbook
  - 同時維持`.codex/skills/minimum-sdd.md`
- Before handover:
  - 讀`.codex/skills/test-case-generation.md`
  - 讀`.codex/skills/validation-review.md`
- Before deployment task creation:
  - 讀`.codex/skills/deployment-package.md`
  - 讀相關deployment playbook
- Magnolia task:
  - 讀`.codex/knowledge/market-architecture.md`
  - 讀`.codex/playbooks/magnolia-flow.md`
- Salesforce/SFCC task:
  - 讀`.codex/knowledge/market-architecture.md`
  - 讀`.codex/playbooks/salesforce-deploy.md`
  - 使用官方`platform-*` skill前讀`.codex/playbooks/sf-skills-overlay.md`
- Cross-platform task:
  - 讀`.codex/knowledge/system-landscape.md`
  - 讀`.codex/knowledge/market-architecture.md`
  - 讀相關playbooks
  - 讀`.codex/skills/deployment-package.md`
- Prod validation:
  - 讀`.codex/playbooks/prod-validate.md`
- Dev/UAT compare:
  - 讀`.codex/playbooks/uat-compare.md`
- Data/Metadata/MCP:
  - 讀`.codex/playbooks/mcp-usage.md`
  - 讀`.codex/playbooks/sf-skills-overlay.md`
- Investigation/documentation:
  - 讀`.agents/skills/evidence-investigation-documentation/SKILL.md`
  - 調查先唯讀，文件編輯需使用者明確授權

## 知識檔
- `.codex/knowledge/repo-map.md`
- `.codex/knowledge/market-architecture.md`
- `.codex/knowledge/system-landscape.md`
- `.codex/knowledge/sap-sis.md`

## 流程檔
- `.codex/playbooks/git-baseline.md`
- `.codex/playbooks/mcp-usage.md`
- `.codex/playbooks/salesforce-deploy.md`
- `.codex/playbooks/magnolia-flow.md`
- `.codex/playbooks/uat-compare.md`
- `.codex/playbooks/prod-validate.md`
- `.codex/playbooks/sf-skills-overlay.md`

## 技能檔
- `.codex/skills/requirement-review.md`
- `.codex/skills/minimum-spec.md`
- `.codex/skills/minimum-sdd.md`
- `.codex/skills/test-case-generation.md`
- `.codex/skills/validation-review.md`
- `.codex/skills/deployment-package.md`
- `.agents/skills/evidence-investigation-documentation/SKILL.md`

## 官方skill
- 來源:`forcedotcom/sf-skills`,原樣保留,來源與hash記錄於`skills-lock.json`
- 位置:`.agents/skills/platform-*/`
- 與repo規則衝突時以`.codex/playbooks/sf-skills-overlay.md`為準

## 補充規則
- 暫存輸出:
  - `~/codex_tmp`
- 完成PR後:
  - 更新本檔案摘要

## 回覆格式
- 依使用者提問的語言回覆;無法判斷時使用台灣繁體中文
- 以中文回覆時:
  - 中英文不加空格
  - 英文保留空格
  - 不使用中文句點
