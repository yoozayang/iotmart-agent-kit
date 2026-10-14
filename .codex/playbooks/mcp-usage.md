# MCP Usage

## 適用情境
- 涉及Data
- 涉及Metadata
- 涉及Target Org
- 需要查官方技術文件
- 需要把調查或結論記錄到Notion

## Target Org與Salesforce MCP
- Target Org以使用者在對話中指定的org為準:
  - 同一對話已指定即沿用,不需重複確認,也不需比對`SF_TARGET_ORG`
  - 未指定時先詢問;詢問前不執行retrieve,query,deploy,validation,dry-run
- `sf`指令一律明確帶`-o <Target Org>`,不依賴預設org
- Salesforce MCP只作用於設定檔的預設org(`.codex/config.toml`的`SF_TARGET_ORG`):
  - 與Target Org相同時可用
  - 不同時改用`sf` CLI
- Prod相關操作另讀`.codex/playbooks/prod-validate.md`;Prod validation或dry-run不是一般查詢,仍須使用者明確授權

## context7
- 當題目涉及library,framework,SDK,API,CLI,cloud service時優先使用
- 用途:
  - 查官方文件
  - 查版本差異
  - 查正確語法或設定
- 不用於:
  - 一般商業邏輯推論
  - repo內部流程判斷

## Notion MCP
- 問題調查完成後:
  - 主動詢問是否建立Notion記錄頁面
- 規格討論完成後:
  - 主動詢問是否建立Notion記錄頁面
- 若使用者同意建立:
  - 記錄背景
  - 記錄結論
  - 區分事實/推論
  - 記錄待確認事項

## 暫存產物
- 研究,查詢,比對過程產生的臨時檔案只放在已exclude的位置,預設`~/codex_tmp`
- Salesforce retrieve compare產物放`~/codex_tmp`時,優先使用`sf project retrieve start --target-metadata-dir ... --unzip`
- 若臨時檔案誤生在repo內,結束前移到已exclude目錄或刪除,不可留下untracked檔案
