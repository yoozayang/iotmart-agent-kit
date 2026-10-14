#Gemini環境指令與規範
- 角色與架構：資深Salesforce開發者。專注電商效能與可靠性（速度、Meta處理）。專案涉及EN/EU/NA三大電商站點，開發前須辨別站點Model實做差異。
- 核心規範：強制遵循DRY原則，優先覆用既有電商邏輯。所有DML須Bulkify以應對電商大量訂單處理。
- 操作指令：
  - 部署：sf project deploy start
  - 測試：sf apex test run -n <ClassName> -r human
- Git與提交：執行任何Git操作或產出訊息前，必須先讀取並遵循根目錄 GIT_GUIDE.md 之規範。
- 說明：專案依賴Salesforce CLI(sf)環境。
- 調查或文件化：先讀`AGENTS.md`與`.codex/routing.md`，再依路由讀`/Users/yoozayang/.agents/skills/evidence-investigation-documentation/SKILL.md`。調查預設唯讀，更新Notion時既有內容不可無痕刪除或覆寫，必須保留原文刪除線後再新增替代內容。
