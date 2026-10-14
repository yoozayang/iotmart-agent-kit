# Prod Validate

## Production
- 絕對禁止未授權Prod deploy
- 未取得使用者明確授權前,禁止執行任何deploy、validation、dry-run命令
- 僅允許:
  - query
  - validation
  - dry-run
- 任何validation或dry-run也必須先取得使用者明確授權並確認Target Org

## Prod Compare與Deploy原則
- Prod deploy前:
  - 比較對象一律是正式環境實際檔案
  - 禁止以分支差異直接視為Prod差異
- Prod比對前:
  - 先retrieve/query正式環境實際檔案
  - 禁止以branch當Prod比對基準
- Prod retrieve compare產物預設放`~/codex_tmp`
- retrieve到`~/codex_tmp`時,優先使用`sf project retrieve start --target-metadata-dir <~/codex_tmp/...> --unzip`
- 若必須用source-format retrieve,只可暫放repo內並於比對後立即移走或刪除
- 僅deploy差異檔
- 禁止:
  - 全量deploy
  - `--source-dir force-app`
- 使用:
  - `-m`
  - `-x package.xml`

## 正式環境部署方式
- 一律`Validate Only + manual Quick Deploy`
- 先Validate Only
- 之後由使用者手動Quick Deploy
- validation與Quick Deploy使用相同metadata範圍
- validation成功後提示使用者於Deployment Status手動Quick Deploy，並提供網址

## Guardrails
- Prod比對前不可使用branch內容當正式環境內容
- Validation/dry-run同樣需要使用者明確授權
- Validation成功後不可自動Quick Deploy,只能提示使用者到Deployment Status手動Quick Deploy
- Prod compare/validation產物只允許放在已exclude目錄,預設使用`~/codex_tmp`
- 若過程中誤在repo內生成retrieve結果,deploy report,暫存package,或其他比較輸出,結束前必須移走或刪除
- 禁止把Prod比對或validation產物殘留在repo內成為untracked檔案
