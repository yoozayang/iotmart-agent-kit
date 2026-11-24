---
name: iotmart-work-recap
description: Use when the user asks what they should work on now, requests a personal work recap, asks for their daily stand-up report (給我日會報告), asks what they did last week or for a weekly review (上禮拜做了什麼、週回顧), or asks about their pending ADO work items, PR reviews, or blockers via the DevOps Tracker MCP (`https://iotmart-tracker.pages.dev/api/client/mcp`).
---

# DevOps Tracker 個人工作 Recap 與日會報告

本 skill 指引 Agent 透過遠端 **DevOps Tracker MCP**（`https://iotmart-tracker.pages.dev/api/client/mcp`）協助每位成員快速盤點「現在應該做什麼」、產出「日會報告」與「週回顧」，無需打開網頁或 clone `devops-tracker` repo

## 1. 接入資訊與前置檢查（所有團隊成員共用同一端點）

- **遠端 MCP 端點**：`https://iotmart-tracker.pages.dev/api/client/mcp`
- **個人認證**：每位使用者必須登入 `https://iotmart-tracker.pages.dev` →「我的工作」→「AI client」自行建立個人 `wsk_...` token，並設定於本機環境變數 `WORKSPACE_CLIENT_TOKEN`（嚴禁共用、代發或寫死他人 token）
- **工具缺失或 401 未授權時（不要重試，清楚引導一次即可）**：
  - 若 tool list 看不到 `get_action_recap` / `get_daily_report_context` 等工具，或回傳 `401` / `syncInfo.tokenBound === false`：
  - 告知使用者：
    1. 前往 `https://iotmart-tracker.pages.dev`「我的工作 → AI client」建立自己的個人 `wsk_...` token
    2. 在 shell / 環境變數設定 `WORKSPACE_CLIENT_TOKEN=wsk_...`，並於自己的 Agent MCP 設定加入遠端端點 `https://iotmart-tracker.pages.dev/api/client/mcp`（含 `Authorization: Bearer ${WORKSPACE_CLIENT_TOKEN}`）
    3. 重新載入 MCP 或開新對話後再詢問

## 2. 情境一：快速 Recap「現在應該幹嘛」

1. 呼叫 `get_action_recap`（帶 `compact: true`，回傳量約少一半；需要完整留言時再用 `get_work_item_detail`）
2. **回覆最開頭必須先列出同步資訊**：
   - `syncInfo.lastAdoSyncAt`（上次 ADO 同步時間）與 `syncInfo.lastPrSyncAt`（上次 PR 同步時間），均以台北時間呈現
   - `syncInfo.syncScheduleNote`（例如目前為 Azure Pipelines 平日 08:05–20:05 每 2 小時同步快照＋週二、四 13:45 加開；D1 共用筆記為即時讀取）
3. 依優先序簡潔整理：
   - **P0 立即處理**（`p0_immediate`）：別人 `@` 我待回覆的項目（`needsMeItems`）、待我審核的 PR（`prsNeedingMyReview`）、我送出但被要求修改或有衝突的 PR（`myBlockedPrs`）
   - **P1 今天推進與等待追蹤**（`p1_active_and_waiting`）：進行中工作（`activeItems`）、等別人回覆或卡在 UAT／待部署項目（`waitingItems`），務必結合 `openNotes` 中的最新共用筆記說明目前卡點
   - **P2 風險與提醒**（`p2_risks`）：`attentionItems` 內的估時缺失／過舊與進度警示
4. 使用者追問單一工作項目或 PR 細節時，再按需呼叫 `get_work_item_detail` 或 `get_pr_detail`

## 3. 情境二：不進 Web 產出「日會報告」

1. 呼叫唯讀工具 `get_daily_report_context`（帶 `compact: true`；此查詢**不會**推進 `reportMarkedAt`）
2. 回覆最開頭先標註資料同步時間（`syncInfo.lastAdoSyncAt`）與報告涵蓋起點（`reportWindow.since`）
3. 嚴格依 `formattingGuide` 以台灣繁體中文產出可直接貼到會議的純文字草稿：
   - 第一行：`YYYY-MM-DD`
   - `1. 已完成`：整理自 `completedSinceReport`（無則寫 `- 無`）
   - `2. 預計要做`：從 `plannedCandidates` 挑選重要項目，最多 6 項（無則寫 `- 無`）
   - `3. 困難/議題`：從 `issueCandidates` 與 `relatedPrs` 整理阻礙或外部依賴，每項一句（無則寫 `無`）
   - 編號規則：`1.` 與 `2.` 寫成 `- [12345] 重點--簡短狀態`，`3.` 寫成 `12345 說明`；**不可使用 `#12345`**，也不可把 Work Item 編號誤稱為 PR；`--狀態` 僅在資料或 `openNotes` 有明確依據時才加
4. 產出草稿後，詢問使用者是否要呼叫 `save_daily_report` 寫回 Web「我的工作 → 日會報告（草稿）」（`personal_briefs`，會保留原本的 AI Brief `content`），並確認是否一併將 `mark_reported` 設為 `true` 以推進下次報告起算時間

## 4. 情境三：週回顧「上禮拜做了什麼、接下來注意什麼」

1. **先決定時間區間並寫在回覆開頭**（台灣時間）：「上週」= 上一個週一到週日；「最近」「這幾天」= 過去 7 天；使用者指定日期則照用。今天若已是週四、週五，「這禮拜要注意什麼」以「今天到下週」為範圍
2. **做了什麼**：呼叫 `get_activity_log`（`since`／`until` 用 `YYYY-MM-DD`）
   - `completedItems`：期間內完成的工作項目（附 `prKeys`）
   - `prsMerged`／`prsOpened`／`prsAbandoned`：我送出的 PR；`prsReviewed`：我參與審核的 PR（依 PR 活動時間推估，請寫「參與審核」，不要寫精確審核日期）
   - `window.coverageNotes` 有內容時要提醒：完成項目只保留近 14 天、已結束的 PR 只保留近 30 天
3. **接下來注意什麼**：呼叫 `get_action_recap`（`compact: true`），依序整理 P0 待回覆與待審 PR → 近期到期（`eta`）的項目 → 等待他人過久的項目 → P2 風險
4. 工作項目寫成 `[12345]`，PR 用 prKey（例如 `ado:3071`）；遠端 MCP 若沒有 `get_activity_log`（舊版伺服器），直接告知無法查詢區間紀錄，不要用其他資料拼湊成完整清單

## 5. 唯讀與安全邊界

- 不可透過此流程修改 Azure DevOps Work Item、PR 或看板團隊共用筆記
- 僅在獲得使用者確認後，才呼叫 `save_daily_report` 更新使用者本人的日會報告草稿與 `reportMarkedAt`
- 嚴守資料事實：不可編造未出現在回傳 JSON 中的編號或狀態
