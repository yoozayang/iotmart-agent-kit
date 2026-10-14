# Salesforce Deploy

## Salesforce
- EU:
  - Dev:`ccdev02`
  - UAT:`ccdev01`
- EN/NA:
  - NQA+Prod

## Split Source Detail Preserved
```text
- EN/NA:
  - Dev:`NQA'
```
- 上述split source detail與原始repo AGENTS.md的`EN/NA:NQA+Prod`並存
- 在人為確認前不可刪除任一描述

## CLI
- 僅`sf`
- 禁止`sfdx`

## Metadata
- 目標org依`.codex/playbooks/mcp-usage.md`的Target Org規則
- 先retrieve再作業與修改
- 禁止本地覆蓋org

## Deploy
- 未取得使用者明確授權前,禁止執行任何deploy、validation、dry-run命令
- 優先:
  - `sf project deploy start -m`
  - `sf project deploy start -x`
- 比對只採目標orgretrieve下來的實際檔案與三方整合結果,不以CLI source tracking作第二次判斷
- 最終manifest定案後,執行`sf project convert source -x <final-package.xml> -d ~/codex_tmp/<task>/mdapi`產生MetadataAPI套件
- 使用`--metadata-dir ~/codex_tmp/<task>/mdapi`做dry-run與部署,兩者必須使用同一套件與測試範圍
- 禁止`--ignore-conflicts`與任何guard bypass
- 部署期間的合併與修補只可存在`~/codex_tmp/<task>`的暫存來源與套件,不可修改目前工作分支
- 若來源程式本身無法編譯或必須修改才能部署,停止部署處理並將修正作為獨立的實作或PR,取得使用者明確授權後才修改來源
- 僅deploy差異檔,前提是充分檢查相依性
- 禁止:
  - 全量deploy
  - `--source-dir force-app`

## Test
- `RunSpecifiedTests`
- 僅相關test
- Dev UAT下僅相關模組test，不跑全部測試，prod應確認
- dry-run與正式deploy使用相同範圍

## Sandbox
- deploy前同步最新sandbox
- deploy前檢查目標檔案
- 非正式環境以整合他人同步工作為預設,不可因有差異就停止
- 已由使用者確認的本次來源版本(包含使用者自己已修改並指定部署的內容)不需重複確認
- 他人修改須先三方整合,保留雙方有效變更後一併部署
- 三方整合的語意衝突不明:
  - 停止並討論
- sandbox test受他人影響:
  - 可暫時`NoTestRun`
  - 不補他人測項

## Guardrails
- Salesforce/SFCC task前先讀`.codex/knowledge/market-architecture.md`
- Dev/UAT/Sandbox比對需讀`.codex/playbooks/uat-compare.md`
- Prod validation需讀`.codex/playbooks/prod-validate.md`
- Data/Metadata/MCP需讀`.codex/playbooks/mcp-usage.md`
