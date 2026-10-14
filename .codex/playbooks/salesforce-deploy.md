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
- source tracking異常:
  - 才允許metadata-dir
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
- 禁止覆蓋他人修改，予以整合保留後一併部署
- 衝突不明:
  - 停止並討論
- sandbox test受他人影響:
  - 可暫時`NoTestRun`
  - 不補他人測項

## Guardrails
- Salesforce/SFCC task前先讀`.codex/knowledge/market-architecture.md`
- Dev/UAT/Sandbox比對需讀`.codex/playbooks/uat-compare.md`
- Prod validation需讀`.codex/playbooks/prod-validate.md`
- Data/Metadata/MCP需讀`.codex/playbooks/mcp-usage.md`
