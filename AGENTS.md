# Codex專案規範

## 第一必要步驟:Ponytail-first evaluation
- 每次任務的第一步在內部完成Ponytail-first evaluation
- 評估與review過程不輸出:不宣告「依Ponytail判斷」,不重述清單,不提框架名稱;只有使用者要求說明決策依據時才展開
- 這是執行流程優先序,不是宣稱改變Codex平台實際instruction載入順序
- 若Ponytail plugin或skill可用,先執行Ponytail評估,再依本檔與既有repo規則實作
- Ponytail plugin要求的結尾說明只在確有未檢查項或風險時寫一行,不標示Ponytail;`ponytail-review`,`ponytail-audit`等報告型skill只在使用者要求時執行
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
- 本檔與playbook明文定義的授權流程(Prod部署授權,獨立軟體例外,個人repo自主合併)是規則本身,不是衝突;不可以「較保守」或預設流程為由拒絕已依該流程授權的操作
- 若不確定規則歸屬,先查對應playbook並消除衝突；不得累加互相矛盾的規則

## 取用順序
1. 先做Ponytail評估
2. 再套用本`AGENTS.md`的硬限制
3. 讀`.codex/routing.md`
4. 依題目載入對應`knowledge`,`playbooks`,`skills`
5. 再產出最小可行實作方案
6. 仍有必要時才改碼
7. 完成後在內部做Ponytail review,只回報需使用者處理的結果

## Repo硬限制
- security/compliance/data integrity/permissions/deployment requirements仍由本repo規範主導
- 絕對禁止未授權Prod deploy
- Deploy、validation、dry-run需取得使用者對目標Org及工作範圍的明確授權並確認Target Org；同一任務已授權即沿用，不得逐條指令反覆詢問
- 檔案比對前:
  - 比較對象一律是對象環境實際檔案
  - 禁止以branch差異直接視為對象環境差異
- Metadata:
  - 先retrieve再修改
- Sandbox:
  - 禁止覆蓋他人修改，以保留org既有開發，與整合本地開發為原則
  - 衝突不明時停止整合，並討論
- Target Org:
  - 以使用者在對話中指定的org為準;同一對話已指定即沿用,不需重複確認,也不需比對`SF_TARGET_ORG`
  - 未指定時,Data/Metadata操作前先詢問
  - `sf`指令一律明確帶`-o <Target Org>`,不依賴預設org
  - MCP只作用於設定檔的預設org;與Target Org不同時改用`sf` CLI

## Deploy硬限制
- 僅deploy差異檔
- 禁止:
  - 全量deploy
  - `--source-dir force-app`
- 使用:
  - `-m`
  - `-x package.xml`
  - `--metadata-dir`僅限以最終`package.xml`執行`sf project convert source -x`產生的MetadataAPI套件
- 修改後:
  - DRY檢查
  - Apex test
- Salesforce CLI:
  - 僅`sf`
  - 不使用`sfdx`
- Prod正式環境部署方式:
  - 預設`Validate Only + manual Quick Deploy`，validation成功後提示使用者於Deployment Status手動Quick Deploy，並提供網址
  - 使用者要求Agent部署Prod時不可拒絕:IoTMart既有業務在validation成功後問一次Y/N，Y後由Agent執行Quick Deploy；流程見`.codex/playbooks/prod-validate.md`
  - 例外:使用者明確聲明為「獨立軟體」的專案可直接部署Prod且不需逐次詢問，範圍與限制見`.codex/playbooks/prod-validate.md`「獨立軟體例外」
- 執行層防護:
  - `sf`經`bin/sf` guard執行，Codex rules與Claude permissions另行要求確認，詳見`.codex/playbooks/sf-skills-overlay.md`
  - 已授權的Prod部署以`--prod-approved <Org>`通過guard；guard因缺少授權阻擋時依流程詢問Y/N，不直接拒絕
  - 其他阻擋停止並回報；禁止以`SF_GUARD_BYPASS`、真實`sf`絕對路徑、MCP或其他方式繞過

## Git基準硬限制
- branch:
  - `feature/*`
  - `bugfix/*`
- 相對差異/新增/回歸判斷:
  - 預設以`origin/Dev`為比較基準
  - 非使用者明確指定時,禁止以`origin/main`作為此repo的預設相對基準
  - 回覆中若提到「這次分支新增/這次修改/相對差異」,都應先以`origin/Dev...HEAD`確認
- Commit/PR:
  - 遵循`GIT_GUIDE.md`；個人repo依`GIT_GUIDE.md`「個人Repository自主完成」自主建立並合併PR，不需逐次要求核准
  - 上述branch命名與`origin/Dev`基準只適用IoTMart專案repo；個人repo依該repo預設branch與慣例
- 大量非功能diff:
  - 優先檢查base branch

## 官方skill
- 來源:`forcedotcom/sf-skills`,原樣保留,來源與hash記錄於`skills-lock.json`
- 位置:`.agents/skills/platform-*/`
- 與repo規則衝突時以`.codex/playbooks/sf-skills-overlay.md`為準

## 協作平台與多Agent環境原則（條件式）
- 僅在運行於多Agent協作平台（如Buzz、多人頻道環境，或接收到協作中繼事件）時生效:
  - 遵循「公開透明（Work in the open）」原則，所有調查、審核結果與交接狀態須在公開頻道發布，確保Owner與全員掌握
  - 具體指令與操作規範詳見Task Routing載入之`.agents/skills/buzz-collaboration/SKILL.md`
- 在非協作平台（本地IDE、單機CLI對話）時，維持原生對話文字輸出，不執行平台發布指令

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
- 預設先報結果與阻礙，不重述背景、內部評估過程或已授權事項
