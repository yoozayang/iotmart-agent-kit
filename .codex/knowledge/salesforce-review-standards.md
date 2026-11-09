# Salesforce Review Standards

Review時Standards軸的IoTMart Salesforce標準與Security觸發條件。來源:`GEMINI.md`,`.gemini/styleguide.md`與`AGENTS.md`硬限制;只在diff含Salesforce程式或metadata時載入

## Standards
- 站點:Model選用符合EN/EU/NA站點電商區域規範,不可把某站點邏輯套到其他站點
- 重用:遵守DRY,優先重用既有電商邏輯,不重複造輪子
- Bulkify:迴圈內不得有SOQL或DML;trigger與handler需能處理單次200筆
- SOQL:查詢條件需含索引欄位;禁止動態SOQL,無法避免時必須使用bind變數
- 效能:避免造成頁面延遲的冗餘SOQL或重複計算;留意CPU,heap,單交易查詢數等governor limits
- 硬寫值:不可硬寫Record Id,Org專屬URL,email收件人或環境專屬設定;改用Custom Metadata,Custom Setting或既有設定物件
- 測試:Apex變更需有對應測試類別,含assertion與bulk情境;不可為湊覆蓋率而移除assertion
- 錯誤處理:不可吞掉例外;對外整合失敗需有可追蹤的錯誤紀錄

## 風險分級
依diff實際內容分級,只要命中一項HIGH即整體為HIGH

| 等級 | 觸發條件 |
| --- | --- |
| HIGH | sharing變更:新增`without sharing`,移除`with sharing`或`inherited sharing` |
| HIGH | CRUD/FLS:使用者可觸及的資料存取缺少`WITH USER_MODE`,`WITH SECURITY_ENFORCED`或`Security.stripInaccessible`;新增`AccessLevel.SYSTEM_MODE` |
| HIGH | 動態SOQL/SOSL或字串串接查詢 |
| HIGH | 對外暴露:`@AuraEnabled`,`@RemoteAction`,`@RestResource`,`@Http*`,`webservice`,`global`方法,Experience Cloud guest或site user可存取的邏輯 |
| HIGH | 外部整合:callout,Named Credential,Remote Site Setting,Platform Event,SAP/SIS介接 |
| HIGH | 權限metadata:Permission Set,Profile,Sharing Rule,Custom Permission |
| HIGH | 金額:價格,幣別,訂單金額,稅,付款相關計算 |
| HIGH | 資料大量異動或刪除:`delete`,`Database.delete`,batch,scheduler |
| HIGH | 移除既有validation,檢查條件,錯誤處理或測試assertion |
| HIGH | 對外寄信:收件人,寄件地址(`OrgWideEmailAddress`)或通知觸發條件變更 |
| MEDIUM | 一般商業邏輯,狀態轉換,新增內部API |
| LOW | 只改UI文字,註解,log,測試資料 |
