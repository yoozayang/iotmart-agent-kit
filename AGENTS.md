# Codex專案規範

## 執行順序
- 每次任務先在內部做Ponytail評估:不改碼→既有程式→平台原生功能→標準庫/已裝依賴→最少檔案與diff;不新增無需求的抽象,檔案,service或架構層
- 有Ponytail skill時先套用;無skill時沿用上述評估
- 不輸出評估或框架名稱;使用者要求說明,或評估造成暫停,縮減,拒絕時說明原因
- 套用本檔硬限制→讀`.codex/routing.md`→依操作載入文件→最小可行方案→必要時改碼→內部review
- Ponytail結尾說明僅在確有未檢查項或風險時保留,不標示名稱;報告型review/audit skill僅在使用者要求時執行

## 權威與路由
- 本檔為根控制入口;安全,合規,資料完整性,權限與部署仍依本repo規範
- 衝突採更嚴格規則;先查對應playbook消除歧義,不得累加矛盾規則
- 明文授權流程是規則本身:Prod部署,獨立軟體例外,Repository自主合併不得被預設流程或「較保守」理由拒絕
- 同一context已讀且未變更的文件沿用;操作改變,文件變更或context遺失時再讀必要部分

## Salesforce硬限制
- Deploy,validation,dry-run須取得Target Org與範圍的明確授權;同一任務授權沿用,不逐條指令重問
- Target Org沿用對話指定值,不需比對`SF_TARGET_ORG`;未指定時,Data/Metadata操作前先問
- `sf`一律帶`-o <Target Org>`;不用`sfdx`;MCP預設org與Target Org不同時改用`sf`
- 檔案環境比對只採目標環境實際檔案;branch差異只作候選清單,不可當環境差異
- Metadata先retrieve再修改;Sandbox須保留org他人修改並整合本地開發,語意衝突不明時停止討論
- 僅deploy差異檔與必要相依;禁止全量deploy與`--source-dir force-app`
- 部署用`-m`,`-x package.xml`;`--metadata-dir`僅限由最終manifest執行`sf project convert source -x`產出的套件
- 修改後做DRY檢查與相關Apex test
- Prod禁止未授權部署;預設Validate Only後提供Deployment Status網址供手動Quick Deploy
- 使用者要求Agent部署IoTMart Prod時,validation成功後只問一次Y/N,Y後Quick Deploy;獨立軟體可依明文例外直接部署,詳見`.codex/playbooks/prod-validate.md`

## Git硬限制
- IoTMart開發branch:`<名字>/feature/<WI編號>_<簡述>`或`<名字>/bugfix/<WI編號>_<簡述>`;建立與沿用規則見`.codex/playbooks/git-baseline.md`
- IoTMart Salesforce相對差異預設用`origin/Dev`,Magnolia用`origin/main`;使用者指定或PR目標優先;以`<base>...HEAD`確認,大量非功能diff先查base
- 命名與基準不套用個人repo;依該repo預設branch與慣例
- Commit/PR遵循`GIT_GUIDE.md`;符合其自主完成條件時自行建立並合併PR,不重複要求核准

## Skills與協作
- `forcedotcom/sf-skills`位於`.agents/skills/platform-*/`,來源/hash見`skills-lock.json`;原樣保留,覆寫依`.codex/playbooks/sf-skills-overlay.md`
- `code-review`與`differential-review`原樣保留;review由`iotmart-code-review`進入,覆寫依`.codex/playbooks/code-review-overlay.md`
- 僅Buzz/多人頻道/協作中繼事件載入`buzz-collaboration`,公開發布調查,審查與交接狀態;本地IDE/CLI維持對話輸出,不執行平台發布

## 交付
- 實作交付前依routing檢查驗證案例與證據
- 調查／規格討論任務完成且未取得紀錄授權時,詢問一次是否建立Notion紀錄;已有授權沿用
- 暫存輸出放`~/codex_tmp`;完成PR後更新本檔摘要
- 依使用者語言回覆;不明時用台灣繁體中文;中文與英文不加空格,英文保留空格,不使用中文句點
- 只輸出回答問題或接續工作所需的資訊，省略重複與過程交代
