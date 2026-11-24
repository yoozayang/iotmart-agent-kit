# Taxonomy seed

Use only when `/Agent-Knowledge` does not exist; afterwards the wiki root is authoritative and its registries grow with the business.

## areas
|area|covers|hints|
|-|-|-|
|Product|商品、目錄、分類、PIS資料|商品,Catalog,Category,PIS|
|Pricing|價格、Pricebook、Entitlement、幣別|價格,幣別,Pricebook,Buyer Group|
|Cart-Checkout|購物車、結帳、報價分享|Cart,Checkout,Quotation|
|Order|訂單生命週期、取消、退貨|訂單,退貨,取消,Order|
|Payment|付款、電匯、Stripe|付款,電匯,催繳,Stripe|
|Fulfillment|庫存、出貨、到貨、包裝、倉別|庫存,出貨,到貨,Warehouse|
|Account-Member|帳號、聯絡人、會員註冊|註冊,Account,Contact,會員|
|Promotion|優惠券、ePoint、虛擬禮品|Coupon,ePoint,獎勵,禮品|
|Service-Case|Case、Inquiry、CLA|Case,Inquiry,客服,CLA|
|Notification|各類通知信與告警|通知信,收件人,Alert,告警|
|Content-UI|Magnolia模板、站台設定、LWC畫面|模板,頁面,site config,LWC|
|Integration|SAP、SIS、APIM介接與同步|SAP,SIS,同步,API|
|Platform-Ops|環境、部署、權限、監控工具|部署,權限,org,監控|
|Agent-Tooling|kit、skill、MCP|skill,agent,MCP,kit|

## aspects
|aspect|meaning|
|-|-|
|Flow|運作流程與行為|
|Config|設定位置與機制|
|Rules|限制、規則、慣例|
|Integration|介接與資料流|
|Inventory|清單盤點|

## systems
|system|platform|repo|owns|
|-|-|-|-|
|sf|Salesforce B2B Commerce(SFCC)|ADO IoTMart 3.0/IoTMart3.0 force-app|商品、價格、購物車、訂單、Apex、Flow、metadata|
|mgnl-lm|Magnolia light module|GitLab magnolia/light-modules|模板、前端JS/CSS、site設定(decorations/multisite)|
|mgnl-base|Magnolia Java|GitLab magnolia/base|Java endpoint、Salesforce串接provider|
|sap|SAP(經SIS/API Hub)|none|帳號、訂單、庫存、出貨|
|kit|agent規則|ADO IoTMart 3.0/iotmart-agent-kit|agent規則與skill|

## markets
|market|sf store|sf site path|magnolia site|
|-|-|-|-|
|global|en|en|none(純SFCC)|
|eu|eu|euvforcesite|en-eu|
|kr|kr|krvforcesite|ko-kr; kr獨立site待確認|
|us|en_us|enus|en-us待確認|

## envs
|env|meaning|
|-|-|
|prod|正式環境|
|uat|sf ccdev01；Magnolia new_uat|
|usuat|sf ccdev06(US UAT)|
|dev|開發；Magnolia new_develop|
