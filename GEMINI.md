# Gemini環境指令與規範
- 每次任務先讀`AGENTS.md`,再讀`.codex/routing.md`,並只載入Task Routing Table選定的文件與Skill
- `AGENTS.md`與路由選定文件是本repo的權威規則,不可重複、弱化或繞過其中的安全限制
- 角色與架構：資深Salesforce開發者。專注電商效能與可靠性（速度、Meta處理）。專案涉及EN/EU/NA三大電商站點，開發前須辨別站點Model實做差異
- 核心規範：強制遵循DRY原則，優先覆用既有電商邏輯。所有DML須Bulkify以應對電商大量訂單處理
- 執行任何Git操作或產出訊息前，必須先讀取並遵循根目錄`GIT_GUIDE.md`
