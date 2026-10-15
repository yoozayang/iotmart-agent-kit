# UAT Compare

## 適用範圍
- 本檔雖命名為`uat-compare.md`,實際適用於Sandbox compare流程
- 預設涵蓋:
  - UAT
  - Dev
- target org是Dev或UAT都套用同一套收斂原則
- 若是Prod比對,改走`.codex/playbooks/prod-validate.md`

## 核心原則
- `origin/Dev...HEAD`只用來圈出「本次開發檔案清單」
- 禁止用`origin/Dev`判斷Sandbox內容是否正確,也禁止拿branch內容直接當Sandbox比對基準
- Sandbox內容是否正確,一律以Sandbox org retrieve下來的實際檔案為準
- 只檢查本次開發檔案清單中的同名檔案,不主動擴大處理無關的Sandbox差異
- 必要相依檔案可納入處理,但必須明確註記為相依而非擴大範圍
- 非正式環境以整合為預設,不可因同名檔案有差異就停止
- 已由使用者確認的本次來源版本(包含使用者自己已修改並指定部署的內容),直接視為待部署版本,不重複要求確認
- 同名檔案有他人同步更新時,先把目標org版本與本次來源做三方整合,不可直接覆蓋他人變更
- 最後只deploy本次開發檔案清單與已註記的相依檔案

## 輸入
- 當前工作分支
- `origin/Dev`
- Sandbox target org
- 本次開發涉及的metadata類型與檔案

## 輸出
- 本次開發檔案清單
- Sandbox實際retrieve檔案
- 比對結果:
  - 可直接部署
  - 需先整合Sandbox他人變更
  - 與本次開發無關,不處理
- 最終deploy範圍
- compare/retrieve臨時產物

## 執行順序
1. 以`origin/Dev...HEAD`產出本次開發檔案清單
2. 清單確認後,只針對這些同名檔案從Sandbox org retrieve實際內容
   - compare產物放`~/codex_tmp`時,優先使用`sf project retrieve start --target-metadata-dir <~/codex_tmp/...> --unzip`
3. 比對本機待部署內容與Sandbox retrieve內容
4. 判斷差異是否為:
   - 已確認的本次來源變更:保留來源版本,不重複詢問
   - Sandbox已有他人更新:先三方整合,保留雙方有效變更
   - 與本次開發無關的歷史差異(僅記錄,不順手一併處理)
5. 僅在有他人同步更新時,將整合結果寫入`~/codex_tmp/<task>/source`的暫存部署來源,不可修改目前工作分支;同一已確認來源不需重複確認
6. 整合完成後重新比對同一份本次開發檔案清單;無需整合時直接定案
7. 最後只deploy這份收斂後的本次開發檔案清單
8. 從目標org再次retrieve最終範圍並確認沒有新的目標變更
9. 將最終manifest轉成`~/codex_tmp/<task>/mdapi`的MetadataAPI套件
   - 指令:`sf project convert source -x <final-package.xml> -d ~/codex_tmp/<task>/mdapi`
10. 以`--metadata-dir`和相同測試範圍執行已授權的dry-run與正式deploy
   - dry-run與正式deploy必須使用同一個MetadataAPI套件
   - 不可使用`--ignore-conflicts`

## 收斂規則
- 最終判定不屬於本次開發有效變更的檔案,自deploy範圍移除
- 需要先整合Sandbox內容的檔案,整合完成前不可納入最終deploy
- 最終deploy範圍必須能對應回本次開發清單中的同名檔案或已註記的必要相依檔案

## 停止條件
- 無法確認Sandbox target org
- 無法產出本次開發檔案清單
- retrieve內容不完整或明顯失真
- 發現Sandbox同名檔案已有他人更新且三方整合出現無法安全判定的語意衝突
- 差異已擴大到本次開發範圍外,且是否屬於相依檔案無法確認

## 修改後
- DRY檢查
- Apex test
- 不補他人測項,不達coverage rate就跳過測試

## 驗證
- deploy前先人工確認最終deploy範圍只包含本次開發檔案清單與已註記相依檔案
- DRY檢查與Apex test使用與正式deploy相同範圍

## 暫存產物
- compare/retrieve產物只放已exclude目錄,預設`~/codex_tmp`
- 若必須用source-format retrieve,只可暫放repo內並於比對後立即移走或刪除
- 交付前不可在repo內殘留retrieve結果,比較輸出,暫存manifest或研究筆記等untracked檔案

## 鏈路提醒
- 涉及Dev或UAT的內容比對,retrieve比對,部署範圍收斂時,都先載入本檔
- 只有Prod比對或Prod validate流程,才改走`.codex/playbooks/prod-validate.md`
