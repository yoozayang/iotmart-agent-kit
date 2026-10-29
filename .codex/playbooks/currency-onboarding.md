# Currency Onboarding

## 適用範圍
- 任一store新增交易幣別(例:en新增SGD,MYR;北美新增CAD),或盤點新增幣別的工項
- 涵蓋程式,設定(含SAP,SIS,付款),流程,驗證四面;依架構選擇套用:
  - SFCC架構(EN,舊北美en_us,前台LWC):A~F,略過G
  - Magnolia+SFCC架構(EU,KR,JP,北美新站en-us):A~G,略過LWC前台項目
- 業務決策(見「待確認決策」)不自行假設,列為待確認
- 說明,流程圖與介入點:Notion「新增幣別統合調整項(SFCC/Magnolia+SFCC)」,位於「幣別同步議題」下
  - https://app.notion.com/p/40849fae448081a3bdf5fc0601e94bf3
  - 盤點範例:47576 CAD https://app.notion.com/p/40849fae448081f09922f6e725b2bacf

## 輸入
- 目標store(`WebStore.Name`),Magnolia site(若有)與新幣別ISO code
- Target Org;未指定時先問
- 盤點任務需讀ADO work item與上述Notion頁

## 現況盤點(唯讀)
1. Org幣別:`SELECT IsoCode, ConversionRate, DecimalPlaces, IsActive FROM CurrencyType`
2. Store幣別:`SELECT Name, SupportedCurrencies FROM WebStore`
3. Price Book幣別分佈:`SELECT Pricebook2.Name, CurrencyIsoCode, COUNT(Id) FROM PricebookEntry WHERE Pricebook2.Name IN (...) GROUP BY Pricebook2.Name, CurrencyIsoCode`
4. `Store_Default_Value.<store>`的`CurrencyISOCode__c`,`AllowedCurrency__c`,`CC_PriceBook_Key__c`,`CC_ITP_PriceBook_Key__c`,`CC_BTO_PriceBook_Key__c`,`Is_Applicable_ePoints__c`;各store欄位組成不同,值以目標org為準
5. `<store>_<CCY>`為key的metadata:`CC_Order_Amount_And_ePoint_Exchange_Rate`,`Wire_Transfer_Bank_Info`
6. Magnolia:light-modules `decorations/salesforce-b2b-commerce/config.yaml`(`currencyEffectiveAccountMapping`,`multisiteMapping`),`webresources/clientlibs/js/shipTo*Country.json`;新站可能只在`new_develop`/`new_uat`
7. 前例:`git show --stat c0e36193d`(PR 2626 [EU] add MYR)
8. Prod唯讀查詢被權限擋下時停止該查詢,SOQL列入待使用者執行清單,不繞過

## 工項與介入點
| 介入點 | 項目 | 角色 |
| --- | --- | --- |
| ⓪ | 業務決策 | PM/BA |
| ① | SAP `ZRATE01`匯率,料件幣別價格,Sales Org可建該幣別訂單 | SAP窗口 |
| ② | Setup→Manage Currencies新增幣別與小數位 | SF Admin |
| ③ | Standard PB新幣別0元entry | 開發 |
| ④ | SIS `IoTMart_Job_SyncPriceToSFDC`(`SyncPriceConfigure`加`<CurrencyTo>`,config不隨Transport,各環境手動改),`IoTMart_Job_SyncITPPriceToSFDC`(Groovy);Transport審核上Prod | SIS管理者 |
| ⑤ | 組裝費`AGS-CTOS-SYS-A`,gift PB,`CC_BTO_Define_Price__c`,Promotion qualifier與`CC_Promotion_Maximum__c` | PM/開發 |
| ⑥ | SFCC程式與metadata(見「程式落點」) | 開發 |
| ⑦ | Payment Gateway,Shipping API(ShipRating幣別,DDP國家清單),稅制 | API owner/財務 |
| ⑧ | Magnolia JCR幣別節點與effective account→Store Settings加入`SupportedCurrencies` | Magnolia開發→SF Admin |
| ⑨ | 驗證 | QA/開發 |

## 順序與閘門
1. ⓪先定案;價格來源非SAP匯率換算時,①④需重新設計
2. ②早於③;③早於④:`API_UpdateListPrice`只在Standard PB已有同SKU同幣別entry時才insert目標PB entry,否則靜默跳過
3. ③作法:合併Standard PB補齊功能(`Matthew/feature/Standard_Price_Book_SyncRuleAdjust`,以`SupportedCurrencies`用USD補0元entry);未合併時以匿名Apex鏡像USD entry(UnitPrice=0,`ExId__c`尾綴改新幣別,Prod無`ANA_Integration_ID__c`);寫Prod資料需使用者明確授權
4. ⑤⑥⑦與④並行,在⑧前部署
5. ⑧最後開放;Magnolia+SFCC必須先建JCR `/sites/<site>/currencies/<CCY>`,再開`SupportedCurrencies`,否則`LanguageAndCurrencyServiceImpl`拋`IllegalStateException`,幣別選單變空

## 程式落點
### SFCC(`force-app/main/default`)
| 落點 | 新增幣別動作 |
| --- | --- |
| `classes/CC_LWC_PromotionService.cls` `freeShippingGapMap` | 加幣別門檻;缺key退回USD金額 |
| `customMetadata/CC_Order_Amount_And_ePoint_Exchange_Rate.<store>_<CCY>` | store使用ePoint時新增 |
| `customMetadata/Wire_Transfer_Bank_Info.<store>_<CCY>`,`AppSetting.<store>_WireTransferWhiteList` | 開放電匯時新增;`CC_LWC_WireTransfer`無銀行記錄檢查已被移除,缺記錄會顯示空白 |
| `AppSetting.en_From_Currency_List`,`CurrencyExchangeRate__c.FromCurrency__c` | 兩處加幣別(現缺SGD,MYR) |
| `Store_Default_Value.<store>.AllowedCurrency__c` | 加幣別;影響`Lwc_Sync_ProductInfoController` IsHasPrice |
| `classes/Lib_StoreHelper.cls` | 寫死各store主幣別;主幣別不變不改 |
| `customMetadata/Country_Info.<store>_<Country>` | `CurrencyIsoCode__c`,`TaxTerm__c`依決策 |
| `RESTOutBound_SAP_Order_ANA_Model.CurrencyItemReplace`,`RESTOutBound_SAP_Account_ANA_Model.Currency_Replace` | 寫死USD;en_us收非USD時改 |
| `RESTOutBound_SAP_Account_EU_Model` | 電匯EUR=01,GBP=07;eu新幣別開電匯時改 |
| `PaymentGatewayStrategy_{en,us,eu,kr}` | 確認Gateway支援;en:TWD走CTBC3Ds其他Stripe,us:AuthorizeNet,eu:Stripe,kr:TossPay |
| AI Search `CC_AISearchService`,`CC_Batch_ReBuildAISearchIndex` | 索引以store_PB_商品_幣別建立;新幣別entry同步後重建索引 |
| `lwcPricingFormat`,通知信`priceFormat`,`Lib_Number` | 小數位非2時改 |
| en_us LWC `enusInYourCart`,`lwcOrderPrintAna`,`enusCheckoutOrderSummary` | 寫死USD或`$`;en_us LWC收非USD時改 |

### Magnolia(LM=`light-modules/advantech-templates`,J=`base/magnolia-ecommerce-sfb2b-connector/src/main/java/info/magnolia/ecommerce`)
| 落點 | 新增幣別動作 |
| --- | --- |
| JCR `/sites/<site>/currencies/<CCY>`;bootstrap `mgnl-bootstrap/salesforce-b2b-commerce/config.sites.xml` | 新增節點(`enable`,`isSupportedOnSalesforce`);子app只能切換既有節點 |
| LM `decorations/salesforce-b2b-commerce/config.yaml` `currencyEffectiveAccountMapping` | 加`<connection>: <CCY>: <account ids>`;需SF有該幣別effective account |
| LM `webresources/clientlibs/js/shipTo*Country.json` | 依決策改國家currency |
| J `filter/AdvantechRedirectFilter.java` `detectIP`,`EffectiveAccountService.SHIP_TO_COUNTRY_PATH` | 非EU站固定site預設幣別,後端國家表寫死EU;依國家自動切幣別時改 |
| LM `js/rightMenu.js` | fallback寫死KRW/EUR;切換國家不改幣別 |
| LM `templates/components/checkout/checkoutContent.ftl` `.bank-info--<CCY>` | 開放電匯時新增 |
| LM `js/sectorhubpage/salesInquiry.js` | 預設EUR,改讀site預設 |
| 價格格式化`Intl.NumberFormat` `currencyDisplay:'code'` | 不需改 |

## 驗證
1. 資料:CurrencyType,`SupportedCurrencies`,Standard/Store/ITP PB新幣別筆數接近USD,組裝費entry
2. 前台:幣別選單,一般品與組裝品價格,組裝費,免運門檻,促銷與coupon
3. Checkout:運費,稅(DDU/DDP),付款授權與退款,Order `CurrencyIsoCode`
4. 下游:SAP訂單幣別與Sales Org,通知信與報價單
5. UAT(`ccdev01`)不寄信;通知驗證改用Prod測試訂單(`IsTestOrder__c`)
6. Apex以`RunSpecifiedTests`跑相關test class

## 待確認決策
- 幣別決定方式:使用者切換,或依Shipping Country自動決定
- 價格來源:SAP匯率換算或獨立售價;進位規則
- 實際以新幣別收款或只顯示;Gateway是否支援
- 免運門檻,促銷,coupon,最低訂購金額
- 新出貨國家稅制與DDU/DDP
- 是否開放電匯與銀行帳戶
- 報表,退款紀錄

## 規則
- 寫死幣別的Map,switch,picklist新增key時,同步確認缺key的fallback行為
- Custom Metadata走metadata部署,不以資料寫入修改
- SFCC依`.codex/playbooks/salesforce-deploy.md`,Prod依`.codex/playbooks/prod-validate.md`;Magnolia依`.codex/playbooks/magnolia-flow.md`
- SAP,SIS,Payment,Shipping API只列工項與窗口,不由Agent操作
- 盤點結果寫入Notion時,task頁依`.codex/skills/task-notion-record.md`建立;通用調整寫回上述統合頁
