# Git Baseline

## Branch
- branch命名原則:
  - 新功能:`使用者名稱/feature/*`
  - 修復:`使用者名稱/bugfix/*`

## 相對差異/新增/回歸判斷
- 預設以`origin/Dev`為比較基準
- 非使用者明確指定時,禁止以`origin/main`作為此repo的預設相對基準
- 回覆中若提到「這次分支新增/這次修改/相對差異」,都應先以`origin/Dev...HEAD`確認

## Commit/PR
- 遵循`GIT_GUIDE.md`

## 大量非功能diff
- 優先檢查base branch

## Guardrails
- 本檔只定義git baseline與diff判斷
- UAT/Sandbox內容正確性不可用`origin/Dev`判斷,需改讀`.codex/playbooks/uat-compare.md`
- Prod內容正確性不可用branch差異判斷,需改讀`.codex/playbooks/prod-validate.md`
