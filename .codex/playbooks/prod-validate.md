# Prod Validate

## Production
- 絕對禁止未授權Prod deploy
- 未取得使用者明確授權前,禁止執行任何deploy,validation,dry-run命令;validation與dry-run同樣需要授權並確認Target Org
- 僅允許:
  - query
  - validation
  - dry-run

## Prod Compare與Deploy原則
- Prod比對與deploy前:
  - 先retrieve/query正式環境實際檔案,以此為比較對象
  - 禁止以branch內容或分支差異當作Prod內容或Prod差異
- 僅deploy差異檔
- 禁止:
  - 全量deploy
  - `--source-dir force-app`
- 使用:
  - `-m`
  - `-x package.xml`

## 正式環境部署方式
- 一律`Validate Only + manual Quick Deploy`
- 先Validate Only,之後由使用者手動Quick Deploy
- validation與Quick Deploy使用相同metadata範圍
- validation成功後不可自動Quick Deploy,只能提示使用者於Deployment Status手動Quick Deploy,並提供網址

## 產物位置
- Prod retrieve compare,validation產物只放已exclude目錄,預設`~/codex_tmp`
- retrieve到`~/codex_tmp`時,優先使用`sf project retrieve start --target-metadata-dir <~/codex_tmp/...> --unzip`
- 若必須用source-format retrieve,只可暫放repo內並於比對後立即移走或刪除
- 若誤在repo內生成retrieve結果,deploy report,暫存package或其他比較輸出,結束前移走或刪除,不可殘留為untracked檔案
