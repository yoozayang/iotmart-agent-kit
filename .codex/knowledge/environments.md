# Environments

## 目的
- 本檔是UAT(`ccdev01`)與Prod環境識別資訊的正式基準位置
- 只記錄非機密識別資訊;禁止寫入帳密,Token,Cookie,Session ID
- 部署,比對,驗證規則仍以`.codex/playbooks/salesforce-deploy.md`,`.codex/playbooks/uat-compare.md`,`.codex/playbooks/prod-validate.md`為準

## Salesforce Org
| 環境 | 建議alias | Org類型 | Org Id | Instance URL |
| --- | --- | --- | --- | --- |
| UAT | `ccdev01` | Sandbox | `00Dfd000001gGz3EAE` | `https://adv--ccdev01.sandbox.my.salesforce.com` |
| Prod | `prod` | Production(DevHub) | `00D280000017Eo3EAE` | `https://adv.my.salesforce.com` |

- alias為各人本機`sf org list`名稱,可能不同;以Org Id確認實際目標
- 本機default org可能被設為Prod:
  - 所有`sf`指令一律明確帶`-o <alias>`,禁止依賴default target org
  - 執行前以`sf org display -o <alias>`核對Org Id
- Prod僅可做唯讀查詢;validation,dry-run,deploy依`.codex/playbooks/prod-validate.md`

## Experience Cloud / Site Domain
| 環境 | my.site.com | salesforce-sites.com |
| --- | --- | --- |
| UAT | `adv--ccdev01.sandbox.my.site.com` | `adv--ccdev01.sandbox.my.salesforce-sites.com` |
| Prod | `adv.my.site.com` | `adv.my.salesforce-sites.com` |

- Site path prefix(兩環境相同):`en`,`enus`(en_us),`euvforcesite`(eu),`krvforcesite`(kr),`CTO`,`advtest`,`MyAdvantech`
- `ccdev01`的Domain清單含`www.iotmart.com`,是Prod refresh殘留,不代表UAT前台網址

## WebStore
| Store | UAT(`ccdev01`) | Prod |
| --- | --- | --- |
| eu | `0ZEfd00000005FpGAI` | `0ZEIi00000000qqOAA` |
| kr | `0ZEfd0000000AqbGAE` | `0ZEfS0000004sWTWAY` |
| en | 無 | `0ZE2y000000bm33GAA` |
| en_us | 無 | `0ZEIi00000000ErOAI` |

- UAT只有eu,kr WebStore;EN/NA測試不可假設`ccdev01`有對應store

## 前台(Magnolia)網址
| 環境 | Domain | 對應SF org |
| --- | --- | --- |
| UAT | `https://iotmart-test.advantech.com` | `ccdev01` |
| Prod | `https://www.iotmart.com` | Prod |

- 市場路徑:
  - EU:`/en-eu/<lang>`
  - KR:`/ko-kr/<lang>`,例`/ko-kr/en`
- KR訂單明細(Store_Default_Value`MyOrderURL__c`):`/ko-kr/Customer-Service/Account/order-details?ref=email&orderNo=<OrderNo>`
- UAT Magnolia Author:`https://uat.author.advantech.magnolia-platform.io/.magnolia/admincentral`
- `ccdev01`部分Store_Default_Value仍指向`www.iotmart.com`(Prod refresh殘留);UAT測試網址以本表為準,不可直接沿用metadata內的網址
- 購物車等其他頁面路徑未在此確認;需要時以實際前台操作或Network紀錄確認,不可猜測

## 登入
- 前台會員登入為Advantech Member OAuth(`member.advantech.com`),非帳密直填SF
- 對應Auth Provider:`IotMart_OAuth_<store>`(例`IotMart_OAuth_kr`,`IotMart_OAuth_eu`),plugin class `IotMart_AuthProvider_PluginClass`
- Agent以Playwright測試時由使用者在瀏覽器手動登入;Agent不經手帳密

## 更新規則
- 本檔資訊來源為唯讀`sf org display`,SOQL(`Network`,`Domain`,`WebStore`,`Store_Default_Value__mdt`)與repo程式碼
- Sandbox refresh後Org Id,WebStore Id可能改變,使用前若有疑義先以唯讀查詢重新確認並更新本檔
