# Magnolia Flow

## Magnolia
- Repo:
  - base/light-modules
- deploy:
  - MR審核後手動deploy
  - 確認base/light-modules相依
  - 避免EU營運時段Prod deploy
- Git Flow:
  - feature基於`main`
  - 禁止直接改`main`
  - `_A`:開發分支
  - `_B`:`_A + new_develop`,使用於Dev環境部署
  - `_C`:`_A + new_uat`,使用於UAT環境部署

## Branch Naming
- 建立任何branch前必須有task number；缺少時先詢問並停止
- `Bug`使用`bugfix`，`Feature/Story`使用`feature`；其他類型先確認
- 格式：`Matthew/<type>/<task-number>_<short-title>`
- 例：`Matthew/bugfix/40780_PromotionFix`

## `_A` Workflow
### Initial development
- 從最新遠端`origin/main`切出`_A`開始開發
- `_A`只包含本次任務的修改

### Before MR
- 先`git fetch origin main`
- 建議從最新`origin/main`重新建立`_A`，再cherry-pick本次任務commit
- 若`_A`歷史只有自己使用，且rebase不會覆蓋他人內容，可改用rebase更新`_A`
- 若commit、歷史或是否會覆蓋他人內容不明確，停止並確認
- push前執行`git diff --name-only origin/main...<branch>_A`；出現非本次預期檔案即停止
- `_A`已存在時，未獲明確授權不得覆寫
- push`_A`並建立target為`main`的MR
- MR建立並填入資訊後停止，不merge、deploy、trigger pipeline或使用browser，除非使用者明確要求

## Merge前
- rebase目標環境

## 大量diff
- 重新確認base

## Deploy機制(light-modules)
- 純檔案同步:
  - `devspace sync --path light-modules/:/mgnl-home/modules --upload-only`
- 無需import/bootstrap:
  - light module由檔案系統直接讀取,改完即生效
- 流程:
  - MR merge → 手動觸發對應`deploy:xxx:sync`(`when: manual`,需使用者授權)

## 新增Dialog注意事項
- 新增前:
  - 檢查本模組`dialogs/`下有無`!inherit:<第三方模組>:...`先例
- 無先例且該模組編譯後看不到原始碼:
  - 不貿然inherit
  - 採純`label:`+`form:`(參考`footer-new.yaml`)

## CSS/SCSS
- 編譯後`.css`與對應`.scss`一併commit進版控
- 非build產生後gitignore,改scss需手動同步.css

## Guardrails
- Magnolia task前先讀`.codex/knowledge/market-architecture.md`
- 若涉及Prod部署,同時讀`.codex/playbooks/prod-validate.md`
- 若涉及跨系統資料責任邊界,同時讀`.codex/knowledge/system-landscape.md`
