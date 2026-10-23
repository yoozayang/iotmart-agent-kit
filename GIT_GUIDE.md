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
- 判定(任一不符即視為團隊repo,依上方PR規範與既有review流程):
  - GitHub:repo owner是使用者本人帳號(`gh repo view --json owner`等於`gh api user`的login),不是organization,且collaborators只有本人
  - Azure DevOps:沒有個人owner概念,只有使用者聲明為個人專案才適用;公司organization下的專案(如`IoTMart 3.0`)一律視為團隊repo
  - 不因具有write或admin權限就推定為個人repo
- 流程:使用者要求完成修改即授權Agent自主完成,不在PR建立後等待手動merge,也不逐次詢問merge
  1. 從預設branch建立branch,commit,push,建立PR
  2. 執行repo既有測試或CI;沒有CI時在本機執行該repo的測試腳本並寫入PR描述
  3. 檢查通過且無衝突後merge:
     - GitHub:`gh pr checks <PR> --watch`通過後`gh pr merge <PR> --squash --delete-branch`;沒有checks時以步驟2的本機測試結果為準;repo未開啟auto-merge時不用`--auto`
     - Azure DevOps:`az repos pr create ... --auto-complete true --squash true --delete-source-branch true`,或對既有PR`az repos pr update --id <PR> --auto-complete true`
- 只在下列情況停下詢問:測試或CI失敗且無法在任務範圍內修正,merge衝突語意不明,平台權限或branch protection要求他人review,所有權不明,或合併會觸發未授權的部署
- 禁止:`gh pr merge --admin`,`az repos pr ... --bypass-policy`,偽造或自我approve繞過必要review,關閉branch protection
- PR合併後若對應的sf或pipeline部署需要授權,仍依`AGENTS.md`與deploy playbook處理
