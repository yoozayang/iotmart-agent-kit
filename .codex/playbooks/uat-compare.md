# UAT Compare

## 適用範圍
- 本檔雖命名為`uat-compare.md`,實際適用於Sandbox compare流程
- 預設涵蓋:
  - UAT
  - Dev
- 若是Prod比對,改走`.codex/playbooks/prod-validate.md`

## UAT deploy前
- 先用`origin/Dev...HEAD`只圈出本次開發有修改的檔案清單
- `origin/Dev`在UAT流程中僅能用來界定「本次開發檔案範圍」
- 禁止用`origin/Dev`判斷UAT內容是否正確,也禁止拿branch內容直接當UAT比對基準
- 實際內容比對對象一律是UAT org retrieve下來的實際檔案
- 只檢查這份本次開發檔案清單在UAT上的實際內容
- 若這些同名檔案在UAT有他人更新,先整合回佈署分支後再deploy
- 禁止擴大處理本次開發無關的UAT差異
- 最後只deploy這份本次開發檔案清單

## Sandbox Deploy前
- 先用`origin/Dev...HEAD`只圈出本次開發有修改的檔案清單
- `origin/Dev`在Sandbox流程中僅能用來界定「本次開發檔案範圍」
- 禁止用`origin/Dev`判斷Sandbox內容是否正確,也禁止拿branch內容直接當Sandbox比對基準
- 實際內容比對對象一律是Sandbox org retrieve下來的實際檔案
- 只檢查這份本次開發檔案清單在Sandbox上的實際內容
- 若這些同名檔案在Sandbox有他人更新,先整合回佈署分支後再deploy
- 禁止擴大處理本次開發無關的Sandbox差異，但相依檔案不在此限
- 最後只deploy這份本次開發檔案清單

## 修改後
- DRY檢查
- Apex test
- 不補他人測項，不達coverage rate就跳過測試

## 目的
- 本流程只處理「本次開發範圍」在Sandbox上的實際內容比對與部署收斂
- `origin/Dev`只用來定義本次開發檔案清單,不可當成Sandbox正確內容基準
- Sandbox內容是否正確,一律以Sandbox org retrieve下來的實際檔案為準
- 若實際target org是Dev或UAT,都套用同一套收斂原則

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

## 建議執行順序
1. 以`origin/Dev...HEAD`產出本次開發檔案清單
2. 清單確認後,只針對這些同名檔案從Sandbox org retrieve實際內容
   - compare產物若要放`~/codex_tmp`,優先使用`sf project retrieve start --target-metadata-dir <~/codex_tmp/...> --unzip`
3. 比對本機待部署內容與Sandbox retrieve內容
4. 判斷差異是否為:
   - 本次開發預期變更
   - Sandbox已有他人更新
   - 與本次開發無關的歷史差異
5. 若Sandbox同名檔案有他人更新,先整合回目前部署分支
6. 整合完成後重新比對同一份本次開發檔案清單
7. 最後只deploy這份收斂後的本次開發檔案清單

## 差異判斷原則
- 只看本次開發檔案清單中的同名檔案
- 不主動擴大修正本次開發無關的Sandbox差異
- 若發現Sandbox有額外不在本次清單中的問題,僅記錄,不順手一併處理
- 若差異來自他人已在Sandbox更新,先整合,不可直接覆蓋
- 若存在必要相依檔案,可納入處理,但必須明確註記為相依而非擴大範圍

## 停止條件
- 無法確認Sandbox target org
- 無法產出本次開發檔案清單
- retrieve內容不完整或明顯失真
- 發現Sandbox同名檔案已有他人更新,但無法判斷如何安全整合
- 差異已擴大到本次開發範圍外,且是否屬於相依檔案無法確認

## 收斂規則
- deploy範圍只允許保留在本次開發檔案清單內
- 若某檔案最終判定不屬於本次開發有效變更,應自deploy範圍移除
- 若某檔案需要先整合Sandbox內容,整合完成前不可納入最終deploy
- 最終deploy範圍必須能對應回本次開發清單中的同名檔案或已註記的必要相依檔案
- compare/retrieve產物只允許放在已exclude目錄,預設使用`~/codex_tmp`
- 若必須用source-format retrieve,只可暫放repo內並於比對後立即移走或刪除
- 若比對過程曾在repo內生成臨時目錄或檔案,交付前必須移到已exclude位置或刪除
- 禁止把retrieve結果,比較輸出,暫存manifest,或研究筆記殘留在repo內成為untracked檔案

## 檢查重點
- 本次開發檔案清單是否完整
- Sandbox retrieve是否只聚焦本次開發同名檔案
- 是否有誤把`origin/Dev`當成Sandbox內容基準
- 是否有誤處理本次開發無關差異
- 是否有覆蓋他人Sandbox更新風險

## 驗證建議
- 比對完成後,先人工確認最終deploy範圍
- deploy前再次確認deploy內容只包含本次開發檔案清單與已註記相依檔案
- DRY檢查與Apex test使用與正式deploy相同範圍

## 鏈路提醒
- 當題目涉及Dev或UAT的內容比對、retrieve比對、部署範圍收斂時,都應先載入本檔
- 只有Prod比對或Prod validate流程,才改走`.codex/playbooks/prod-validate.md`
