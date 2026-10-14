# MCP Usage

## 適用情境
- 涉及Data
- 涉及Metadata
- 涉及Target Org
- 需要查官方技術文件
- 需要把調查或結論記錄到Notion

## Salesforce MCP
- 任何Data/Metadata操作前:
  - 先確認Target Org
- 若`SF_TARGET_ORG`與使用者指定環境或任務需求不符:
  - 先提醒,不要直接操作
- 未確認Target Org前:
  - 不執行retrieve
  - 不執行query
  - 不執行deploy
  - 不執行validation
  - 不執行dry-run
- Prod相關操作:
  - 另讀`.codex/playbooks/prod-validate.md`

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

## Guardrails
- 任何Data/Metadata操作前必須先確認Target Org
- 若`.codex/config.toml`的`SF_TARGET_ORG`與使用者指定或任務需求不符,先提醒
- Prod validation或dry-run不是一般查詢,仍須使用者明確授權並確認Target Org
- 研究,查詢,比對過程產生的臨時檔案只允許放在已exclude的位置,預設使用`~/codex_tmp`
- Salesforce retrieve compare若要把產物放在`~/codex_tmp`,優先使用`sf project retrieve start --target-metadata-dir ... --unzip`
- 若臨時檔案誤生在repo內,結束前必須移動到已exclude目錄或直接刪除
- 禁止把研究或比對產物留在repo內形成untracked noise
