#IoTMart GIT & PR 指導規範

## [Commit Message 簡化原則]
格式：<type>: <description>
- feature:新功能開發
- fix:修復Bug
- refactor:重構代碼(非新功能或修復)
- docs:文件變更
- test:增加或修改測試
- style:格式修改(不影響邏輯)
範例：`feature:增加EU站點訂單Model處理邏輯`

## [Pull Request 規範]
- 核心原則：所有PR必須具備清晰描述、測試證明、SPEC更新與WI追蹤。
- Description：簡述背景與業務價值。
- Implementation：列出實作步驟與修改檔案。
- Actual Changes：區分Additions(新組件)與Updates(既有修改)。
- Testing：記錄測試場景、預期結果與驗證人。
- SPEC & WI：更新AzureDevOps工作項狀態。PR合併後，必須將此描述貼回對應WI摘要。

## [個人Repository自主完成]
- 僅當repository owner為使用者本人、沒有其他維護者/團隊協作要求，且使用者已授權完成任務時適用；不因具有write權限就推定為個人repo
- Agent應自主完成branch、commit、push、PR、檢查結果與merge，不要停在PR建立後等待使用者手動merge
- Merge前須確認CI/測試成功、無衝突、符合branch protection及必要review；若平台禁止作者自我approve，不得偽造review或繞過保護
- 遇到失敗、未知所有權、敏感部署或需要額外授權時才詢問使用者
- 團隊repo維持既有review與merge政策；此個人repo規則不覆蓋公司專案流程
