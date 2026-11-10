# Git Baseline

## Branch命名
- 格式:`<名字>/<type>/<WI編號>_<簡述>`,例:`Matthew/bugfix/47151_MailControllerRecipient`
- `<名字>`:使用者的名字(first name),取`git config user.name`的名字部分(如`MatthewYang`→`Matthew`);無法判斷時詢問一次並沿用
- `<type>`:Bug用`bugfix`,Feature/User Story用`feature`;其他WI類型先確認
- `<簡述>`:英文,不含空白
- 建立branch前必須有WI編號;缺少時先詢問並停止

## 開發分支自動建立
- 開始實作IoTMart專案repo的ADO WI時,若目前branch不屬於該WI,Agent直接建立開發分支,不需另外詢問
- 建立前先`git fetch`;本機或遠端已有含該WI編號的branch時沿用,不重複建立
- 基準:Salesforce從`origin/Dev`切出;Magnolia依`.codex/playbooks/magnolia-flow.md`從`origin/main`切出
- 工作目錄有未提交變更時停止並詢問,不得把其他工作帶進新分支
- 建立或切換後依`.codex/playbooks/wi-development-handoff.md`把Repository與Branch寫進WI Description
