# Prod Validate

## Production
- 預設TargetOrg:`prod`;使用者在對話中明確指定其他Prod org時,以使用者指定為準
- 任何Prod metadata操作前,先執行`sf org display -o <TargetOrg> --json`確認該別名已認證;失敗即停止,不可改用CLI建議的其他org
- 絕對禁止未授權Prod deploy
- Query不需授權;validation,dry-run需使用者授權並確認Target Org;正式部署依下方授權流程
- 同一任務內授權持續有效,不逐條指令重問

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
- 使用者只要求validation,或未要求Agent部署時:`Validate Only + manual Quick Deploy`,validation成功後提示使用者於Deployment Status手動Quick Deploy,並提供網址
- 使用者要求Agent部署Prod時,不可以預設流程或內部政策拒絕,依下列授權流程執行
- IoTMart既有業務:
  - 完成Prod retrieve比對,相依性,衝突檢查後先validation(test level依`.codex/playbooks/salesforce-deploy.md`,不另外詢問)
  - validation成功後只問一次:「是否授權將<manifest>部署至<Org>(validation <Job Id>,測試<結果>)?Y/N」
  - Y:`sf project deploy quick --job-id <Job Id> -o <Org> --prod-approved <Org>`;N:停止並提供手動Quick Deploy網址
- 獨立軟體(見下方例外):使用者在本任務要求部署至Prod即為授權,不另問Y/N,直接以`--prod-approved <Org>`執行
- 執行層:
  - `bin/sf`對Prod的`deploy start`/`deploy quick`只接受`--prod-approved <與-o相同的Org>`,不接受環境變數;此flag由guard移除後才交給真實`sf`
  - Windows沒有`bin/sf` guard,真實`sf`不認得此flag,不加`--prod-approved`,授權確認只靠Y/N與Codex/Claude核准
  - Codex rules與Claude permissions仍會對該指令跳出核准,這是同一次授權的執行確認;Y/N可在對話問,或直接以該核准視窗作為Y/N(執行前先列出Org,manifest,測試結果),兩者擇一,不重複詢問
  - 對話中未取得Y,或核准視窗被拒,不可加`--prod-approved`
- 授權範圍:
  - 僅限本次任務,指定Org與該manifest;不延伸至資料寫入,刪除,匿名Apex或其他任務
  - manifest或Org變更,或發現同名衝突與未預期差異時,停止並重新取得授權
- Quick Deploy沿用成功的server-side validation,不需要CLI來源追蹤

## 獨立軟體例外
- 定義:使用者明確聲明為「獨立軟體」的專案;有自己的repo與部署pipeline,只部署自身元件,不修改IoTMart既有metadata
- 已聲明:
  - `IoTMart.ArchitectureViewer`(Azure DevOps`IoTMart 3.0`專案)
  - 使用者在對話中聲明為獨立軟體且符合上述定義的其他專案,於該任務適用
- 允許:
  - 由該專案pipeline在推送`main`後直接部署Prod,不需Validate Only與手動Quick Deploy
  - 該專案對各環境的部署不需逐次詢問授權
- 仍須遵守:
  - 只以該專案`manifest/package.xml`部署,禁止全量deploy與`--source-dir force-app`
  - 元件不得覆寫IoTMart既有或他人的metadata;同名衝突時停止並回報
  - Prod test level依該專案設定,變更需使用者確認
  - 由本機CLI部署時以`--prod-approved <Org>`通過guard,不得以其他方式繞過guard

## 產物位置
- Prod retrieve compare,validation產物只放已exclude目錄,預設`~/codex_tmp`
- retrieve到`~/codex_tmp`時,優先使用`sf project retrieve start --target-metadata-dir <~/codex_tmp/...> --unzip`
- 若必須用source-format retrieve,只可暫放repo內並於比對後立即移走或刪除
- 若誤在repo內生成retrieve結果,deploy report,暫存package或其他比較輸出,結束前移走或刪除,不可殘留為untracked檔案
