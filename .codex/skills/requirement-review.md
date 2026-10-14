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
- Requirement Summary
- Current Understanding
- Missing Information
- Open Questions
- Potential Risks
- Suggested Clarification Questions

## Guardrails
- Do not design or implement before identifying missing information and risks
- Do not assume Prod,UAT,Dev,target org,market,or platform responsibility when not specified
- For Data/Metadata/MCP tasks,confirm Target Org first
- If Prod validation,dry-run,or deploy may be involved,stop before commands until explicit authorization is obtained
- Preserve fact vs inference separation when writing investigation notes

## 外部資源存取規範 (Azure/Notion/Salesforce/GitLab)
- **Notion**：讀取根目錄 `.env` 的 `NOTION_API_KEY`，以連結末 32 位 hex 作為 page_id 調用 Notion API 獲取 Markdown，
- **Azure**：使用本地 SSH 金鑰進行 Git 與 WIT 驗證，
- **Salesforce**：直接執行 `sf` 指令（預設組織為 `ccdev01`），無需登入，
- **GitLab**：使用 `~/.ssh/id_gitlab_antigravity` 密鑰進行代碼倉庫 SSH 存取，
