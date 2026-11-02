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

## [使用者核准即可合併的Repository自主完成]
- 判定:目標分支的實際branch policy與PR必須只要求目前使用者核准，不要求其他人核准。GitHub與Azure DevOps均以此為準，不以repo owner、organization或write/admin權限推定
- 每次合併前必須讀取PR的required reviewers與policy狀態。無法證實僅需目前使用者核准、存在其他人required review或有未通過policy時，視為團隊repo並依上方PR規範處理
- 流程:使用者要求完成修改即授權Agent以目前使用者身分自主完成，不在PR建立後等待手動核准或手動merge
  1. 從預設branch建立branch,commit,push,建立PR
  2. 執行repo既有測試或CI;沒有CI時在本機執行該repo的測試腳本並寫入PR描述
  3. 檢查通過且無衝突後由Agent核准並merge:
     - GitHub:核准PR後`gh pr merge <PR> --squash --delete-branch`;沒有checks時以步驟2的本機測試結果為準;repo未開啟auto-merge時不用`--auto`
     - Azure DevOps:核准PR後使用`az repos pr update --id <PR> --auto-complete true --squash true --delete-source-branch true`
  4. 合併後，若該任務已取得明確Target Org與範圍授權，Agent執行對應deploy流程
- 只在下列情況停下詢問:測試或CI失敗且無法在任務範圍內修正,merge衝突語意不明,required review或policy需要其他人,或deploy尚未取得明確Target Org與範圍授權
- 禁止:`gh pr merge --admin`,`az repos pr ... --bypass-policy`,關閉branch protection或以其他方式繞過未通過policy
- PR合併後若對應的sf或pipeline部署需要授權,仍依`AGENTS.md`與deploy playbook處理
