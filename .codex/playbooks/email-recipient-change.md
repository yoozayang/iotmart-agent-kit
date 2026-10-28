# Email Recipient Change

## 適用範圍
- 使用者(PM,OP,IT)以自然語言要求查詢或異動IoTMart通知信收件人,例如「列出退貨信的收件人」「砍掉xx收件人加上oo」
- 只改收件人,寄件人OWEA與Email Template;不改Apex,Flow邏輯或通知觸發條件
- 需改程式才能達成時,停止並說明原因,轉為開發需求

## 對照來源
- 通知與設定的對照以`force-app/main/default/lwc/emailConfigGovernance/emailNotificationCatalog.js`為準
  - `NOTIFICATION_CATALOG`:通知名稱(`labelZh`),分類,`configSources`,`consumers`
  - `NOTIFICATION_SETTINGS`:每個AppSetting Key對應的通知與用途;同一Key可能被多個通知共用
- Email Alert名稱,收件人欄位與CC:`force-app/main/default/staticresources/EmailDeliveryCatalog.json`的`alerts`,實際值以目標org retrieve為準
- repo內容只用來定位,現值一律以目標org查詢或retrieve結果為準

## 流程
1. 確認Target Org;未指定時先問,PM需求通常是`prod`
2. 依使用者描述找出通知;對應不只一個或不確定時,列出候選讓使用者選
3. 列出現值,依來源分列:
   - `AppSetting__mdt`:`Key__c`,`Value__c`
   - `Remote_Site_Info__mdt`:`To_Email__c`,`CC_Email__c`,`BCC_Email__c`,`Is_Send_CountryOP__c`,`Is_Send_CountrySales__c`
   - `Country_Info__mdt`/`OP_ID_Mapping__mdt`:OP/Sales email欄位
   - Workflow Email Alert:`recipients`(欄位型收件人標示「依訂單帶入」)與`ccEmails`
4. 擬定修改並列出修改前後差異,同時標出影響範圍:
   - Key或Alert被其他通知共用
   - `Country_Info__mdt`/`OP_ID_Mapping__mdt`被多個通知共用,改了會影響同國別所有通知
   - 移除Email Alert的欄位型收件人會影響所有訂單
5. 以Target Org,修改差異與影響範圍取得使用者一次Y/N;Y即視為本次部署授權
6. 套用:
   - retrieve目標記錄後只改指定欄位,以`-m`部署單筆metadata(例:`CustomMetadata:AppSetting.<DeveloperName>`,`WorkflowAlert:Order.<AlertName>`)
   - Prod依`.codex/playbooks/prod-validate.md`:validation後以步驟5的Y執行Quick Deploy,不另外再問
7. 回讀確認後回報:修改前後值,部署Id

## 規則
- 多個Email以`;`分隔,每個都需符合email格式
- 不清空`iotmart_LastResort_Recipients`與必填的寄件人Key
- 目標記錄不存在時不自行新增,回報缺漏並轉為開發需求
- Email Alert的CC異動後,`EmailDeliveryCatalog.json`的寄送監控快照不會自動更新;回報時提醒
- 不使用匿名Apex或資料寫入改設定;Custom Metadata一律走metadata部署
- Agent以metadata部署修改時不會產生面板的異動紀錄快照;回報時務必列出修改前後的值與原因,作為紀錄
