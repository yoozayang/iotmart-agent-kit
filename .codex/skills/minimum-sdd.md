# Minimum SDD Skill

## Purpose
- Help the agent produce a Minimum SDD before implementation
- State what will change,where it will change,expected behavior,validation,and risks

## When To Use
- Before implementation
- During implementation when the task needs a lightweight design anchor
- When multiple systems,metadata types,or deployment constraints are involved

## Required Inputs
- Requirement Summary
- Relevant routing decision from`.codex/routing.md`
- Relevant knowledge/playbook files
- Current code or metadata inspection results
- Known constraints from`AGENTS.md`
- Read user specified task page (e.g. Azure with task number or url) 

## Expected Outputs
- 標題帶狀態與日期:`SDD（定案：YYYY-MM-DD）`;未定案寫`SDD（草稿）`
- 一張表`項目|做法|位置`:每列一件要做的事,做法一句話,位置寫檔案或metadata;不變的部分合成一列「維持現狀」
- 表外只放實作需要的常數(如設定值)與3到5條可檢查的驗收結果
- 依據,數據,討論過程放技術點記錄或討論更新項;未定事項放待確認事項;都不寫進SDD
- 不寫鋪陳,重述或理由說明

```
## SDD（定案：YYYY-MM-DD）
| 項目 | 做法 | 位置 |
|---|---|---|
| <要做的事> | <一句話> | <檔案或metadata> |
| 維持現狀 | <不變的範圍> | — |

<常數名稱>:<值>

驗收
- <可檢查的結果>
```
