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
