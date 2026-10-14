# Market Architecture

## 架構模型
- EN/NA:
  - 純SFCC/B2B Commerce
  - FE/Commerce由SFCC處理
- EU:
  - Magnolia+SFCC
  - Magnolia:FE/template/content/render
  - SFCC:product/pricing/cart/checkout/order
- KR/JP:
  - 延伸EU模型，多為當地幣別、支付方式的差異才會有功能分叉

## 問題定位
- 前端檢查：EU/KR/JP工作不檢查lwc相關內容，EN/NA不檢查magnolia內容，如不明確要停止工作並詢問使用者
- UI/template/content:
  - 優先Magnolia或lwc
- product/pricing/cart/order:
  - 優先SFCC

## 問題分類
- Content page / Template / Rendering:
  - 優先Magnolia
- Product / Catalog / Category:
  - 優先SFCC
- Pricing / Pricebook / Entitlement:
  - 優先SFCC
- Cart / Checkout / Order:
  - 優先SFCC
- Cross-system data ownership:
  - 改讀`.codex/knowledge/system-landscape.md`

## 使用規則
- 先用本檔判斷市場與主責系統
- 若題目涉及跨系統整合、資料流向、外部系統責任邊界,再讀`.codex/knowledge/system-landscape.md`
- 若題目已明確落到部署、retrieve、比對、validation流程,改讀對應playbook

## Magnolia Light Module共用架構
- advantech-templates:
  - 所有站台(KR/EU/en-us/kr等)共用同一份light module程式碼
  - 無per-site複製,改一次全站生效
- Site config位置:
  - `light-modules/advantech-templates/decorations/multisite/config.sites.<site>.yaml`

## 站台預設語言(fallback locale)
- 由各site config的`i18n.fallbackLocale`決定,非Magnolia自動判斷
- Class:
  - `info.magnolia.cms.i18n.DefaultI18nContentSupport`
- Fallback是per-property層級,非整組dialog一起fallback
- 已知設定(2026-09-17查證):
  - ko-kr(`/ko-kr`):ko
  - kr(`/kr`,獨立site定義):en_US,待確認是否仍在使用
  - en-eu:en_US
  - en-us:en_US
