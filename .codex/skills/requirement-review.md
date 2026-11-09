# Requirement Review Skill

## Purpose
- Help the agent review a task before solution design
- Clarify scope,known facts,missing information,open questions,and risks before implementation
- Check with user about original e.g. Azure task number or plain text+image input

## When To Use
- Requirement clarification
- User asks for analysis before solution design
- Task spans Salesforce,SFCC,Magnolia,SAP/SIS,or cross-platform boundaries
- Requested change may require deploy,validation,dry-run,metadata retrieve,or target org confirmation

## Required Inputs
- User request
- Relevant repo context
- Any linked ticket,PR,Notion page,or business description if provided
- Relevant routing output from`.codex/routing.md`
- Relevant knowledge/playbook files selected by routing

## Expected Outputs
- 任務紀錄涵蓋:Requirement Summary,Current Understanding,Missing Information,Open Questions,Potential Risks,Suggested Clarification Questions
- 對話先列差異,不重述使用者已知背景,也不重複已寫入紀錄的細節:
  - 差異:WI,前期工項,目標環境現況之間的落差,每項附證據來源
  - 需使用者決定的項目
  - 需轉問PM的問題
- 已驗證的事實與證據直接寫入任務紀錄,不在對話重複
- 使用者追問時才用白話展開,不預設對方熟悉平台術語,自訂與內建物件或欄位要區分
- 給PM的問題先寫前提與現況,再提問;有建議做法時附理由
- 能從WI,程式或資料推出答案的項目,直接寫入確定版並附依據,不列為待確認;待確認只留需使用者或PM決定的事
- 開發交接:討論定案後才更新任務紀錄的確定版;開發agent只依確定版實作,未定項目留在待確認,不作為開發依據;交接時仍有待確認項目,交接提示詞須寫明遇到時的處理方式

## Guardrails
- Do not design or implement before identifying missing information and risks
- Do not assume Prod,UAT,Dev,target org,market,or platform responsibility when not specified
- For Data/Metadata/MCP tasks,use the Target Org named in the conversation; ask only if none has been named
- If Prod validation,dry-run,or deploy may be involved,stop before commands until explicit authorization is obtained
- Preserve fact vs inference separation when writing investigation notes

## 外部資源存取規範 (Azure/Notion/Salesforce/GitLab)
- **Notion**：優先使用Notion MCP；沒有MCP時讀取根目錄 `.env` 的 `NOTION_API_KEY`，以連結末 32 位 hex 作為 page_id 調用 Notion API 獲取 Markdown
- **Azure**：使用本機 SSH 金鑰(依 `~/.ssh/config` 設定)進行 Git 與 WIT 驗證
- **Salesforce**：直接執行 `sf` 指令，以對話中指定的 Target Org 帶入 `-o`；Target Org 規則見 `.codex/playbooks/mcp-usage.md`
- **GitLab**：使用本機 SSH 金鑰(依 `~/.ssh/config` 設定)進行代碼倉庫存取
