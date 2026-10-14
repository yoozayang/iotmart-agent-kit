# SF Skills Overlay

## 目的
- 本檔覆寫`.agents/skills/`內官方`forcedotcom/sf-skills`的行為
- 官方skill原樣保留,不手改;與repo規則衝突時一律以本檔與`AGENTS.md`為準
- 本檔同時收錄官方skill不涵蓋的repo補強規則

## 適用skill
| Skill | 用途 | 執行權限 |
| --- | --- | --- |
| `platform-metadata-api-context-get` | 寫或改`*-meta.xml`,retrieve前確認型別、成員命名、目錄 | 本地查閱 |
| `platform-data-and-tooling-api-context-get` | 寫SOQL前確認標準物件與Tooling物件欄位 | 本地查閱 |
| `platform-metadata-retrieve` | retrieve指令模式與flag | 依本檔Retrieve規則 |
| `platform-metadata-deploy` | deploy,validate的flag,manifest,錯誤排除 | 僅知識參考,agent不可自行執行 |
| `platform-soql-query` | SOQL寫法與查詢指令 | 唯讀 |
| `platform-apex-test-run` | 測試執行與覆蓋率解析 | 依本檔Test規則 |

## 通用覆寫
- Target Org:
  - 官方skill「未指定org時使用預設org」不適用
  - 任何org操作前必須確認Target Org,`SF_TARGET_ORG`不符要先提醒
- 工具:
  - retrieve,deploy,validate一律用`sf` CLI,不使用MCP metadata工具
  - SOQL查詢可用CLI或MCP
- 暫存:
  - 查詢結果,retrieve比對產物,測試報告一律放`~/codex_tmp`
  - 禁止在repo內留下untracked產物

## Retrieve規則
- 先retrieve再修改
- 比對用retrieve一律:
  - `sf project retrieve start -m "<Type>:<Name>" -o <ConfirmedTargetOrg> --target-metadata-dir ~/codex_tmp/<task> --unzip`
- 禁止:
  - `--ignore-conflicts`,會覆蓋他人或本地修改
  - `--source-dir force-app`整包retrieve進repo
  - 官方`.agents/skills/platform-metadata-retrieve/references/retrieval_modes.md`中直接覆寫`force-app`的範例
- 官方引用的`platform-manifest-generate`在上游不存在:
  - manifest改用`sfdx-git-delta`或`sf project generate manifest`
  - 產生失敗時中止,禁止退回全量manifest

## Deploy規則
- 官方`platform-metadata-deploy`的下列內容僅供理解,禁止照做:
  - `sf project deploy start --source-dir force-app`
  - `sf project deploy start --dry-run --source-dir force-app`
  - `references/deploy.sh`以目錄為單位的部署
- 一律依`.codex/playbooks/salesforce-deploy.md`與`.codex/playbooks/prod-validate.md`:
  - 未取得使用者明確授權前,禁止deploy,validation,dry-run
  - 僅`-m`或`-x package.xml`差異部署
  - Prod一律Validate Only+手動Quick Deploy
- 部署範圍:
  - `origin/Dev...HEAD`只是候選清單
  - 需與目標org實際檔案比對後定案

## Test規則
- test level依`.codex/playbooks/salesforce-deploy.md`
- Dev,UAT僅跑相關test,不跑全部
- Prod test level需與使用者確認

## Repo補強規則
- SOQL前確認自訂物件欄位:
  - 先讀`force-app/main/default/objects/<Object>/fields/`
  - 本地沒有時用`sf sobject describe -s <Object> -o <ConfirmedTargetOrg>`
  - `platform-data-and-tooling-api-context-get`不涵蓋`__c`與`__mdt`
- 自訂物件回報`sObject type ... is not supported`時:
  - 先懷疑查錯org,確認Target Org與市場
  - 例:`Audit_Trail__c`,`CC_BTO_Define__c`只存在部分org
- 標準物件名稱以context skill為準:
  - 例:購物車是`WebCart`不是`Cart`
- 多個metadata成員:
  - 每個成員各用一個`--metadata`
  - 禁止以逗號串成一個值
- 不確定的flag:
  - 先執行`sf <command> --help`確認
- Tooling物件:
  - `DeployRequest`,`ApexCodeCoverage`等查詢需加`--use-tooling-api`
- 非Metadata型別:
  - `OrgWideEmailAddress`等為sObject,不可當metadata retrieve,先查`platform-metadata-api-context-get`確認型別存在

## 執行層防護
| 層 | 位置 | 作用 | 適用 |
| --- | --- | --- | --- |
| `sf` wrapper | `bin/sf`,經shell設定檔放在PATH最前 | 寫入org的指令必須明確`-o`;Prod只允許`deploy validate`;禁止目錄部署,無範圍部署,`--ignore-conflicts`;Prod禁止資料寫入,匿名Apex,`delete source`;禁止`org delete` | Codex,Claude Code,Gemini,終端機 |
| `sfdx` blocker | `bin/sfdx` | 一律阻擋 | 同上 |
| Codex rules | `.codex/rules/sf-guard.rules`,連結到`~/.codex/rules/iotmart-sf-guard.rules` | 寫入org的指令一律prompt;`sfdx`,`sf org delete`,bypass為forbidden;最嚴格者優先,蓋過`default.rules`的allow | Codex |
| Claude permissions | `.claude/settings.json` | 寫入org的指令ask;`sfdx`,`sf org delete`,bypass,MCP `deploy_metadata`,`delete_org`為deny | Claude Code |
| MCP | `.codex/config.toml`,`.gemini/settings.json`,`~/.claude.json` | Salesforce DX MCP不啟用`metadata` toolset | 三者 |
| Org登入 | `sf` CLI | Prod平時不保持登入,取得授權後才`sf org login web -a prod`,完成後`sf org logout -o prod` | 全部 |

- 被guard阻擋時:
  - 停止並回報使用者阻擋原因
  - 禁止以`SF_GUARD_BYPASS=1`,真實`sf`絕對路徑,MCP或其他方式繞過
- `SF_GUARD_BYPASS=1`僅限使用者本人在終端機使用

## 上游更新
- 以`npx skills update`或重新`npx skills add forcedotcom/sf-skills -s <skill> -a codex -y`更新
- 更新後檢查本檔覆寫項目是否仍對應官方內容
- 不手改官方skill檔案
