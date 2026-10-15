# Prod Validate

## Production
- 預設TargetOrg:`prod`;使用者在對話中明確指定其他Prod org時,以使用者指定為準
- 任何Prod metadata操作前,先執行`sf org display -o <TargetOrg> --json`確認該別名已認證;失敗即停止,不可改用CLI建議的其他org
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
  - `--metadata-dir`僅限由最終`package.xml`轉出的MetadataAPI套件
- validation前在`~/codex_tmp/<task>/source`建立固定來源快照,只用此快照與定案的manifest作業
- 先retrieve正式環境最終範圍並比對,確認相依性與測試範圍後才執行ValidateOnly
- 將最終manifest轉成`~/codex_tmp/<task>/mdapi`的MetadataAPI套件後,以`sf project deploy validate --metadata-dir`驗證

## 正式環境部署方式
- 一律`Validate Only + manual Quick Deploy`
- 先Validate Only,之後由使用者手動Quick Deploy
- validation與Quick Deploy使用相同metadata範圍
- validation成功後不可自動Quick Deploy,只能提示使用者於Deployment Status手動Quick Deploy,並提供網址
- Quick Deploy沿用成功的server-side validation,不需要CLI來源追蹤

## 產物位置
- Prod retrieve compare,validation產物只放已exclude目錄,預設`~/codex_tmp`
- retrieve到`~/codex_tmp`時,優先使用`sf project retrieve start --target-metadata-dir <~/codex_tmp/...> --unzip`
- 若必須用source-format retrieve,只可暫放repo內並於比對後立即移走或刪除
- 若誤在repo內生成retrieve結果,deploy report,暫存package或其他比較輸出,結束前移走或刪除,不可殘留為untracked檔案
