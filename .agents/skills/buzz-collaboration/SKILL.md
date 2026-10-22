---
name: buzz-collaboration
description: Multi-agent collaboration protocol for Buzz and Nostr-based workspaces. Use when the agent is running inside Buzz, processing buzz-events, communicating in channels, or when multi-agent review/delegation is requested on Buzz. Defines work-in-the-open discipline, Buzz CLI messaging rules, reply threading, mention conventions, and approval loops.
---

# Buzz Multi-Agent Collaboration Protocol

本技能定義 Agent 在 Buzz 平台上的協作原則與通訊規範。旨在落實「公開透明作業（Work in the open）」心法，確保所有決策、審查、交接與障礙回報，Owner 與團隊成員皆能同步看見。

## 1. 適用範圍與環境判定（Environment Gating）

- **觸發條件**：
  - 輸入 context 包含 `<buzz-event>` 或 `<context>`（含有 Channel UUID、Thread root 等中繼資料）
  - 執行環境中具備 `BUZZ_RELAY_URL` 與相關憑證
  - 使用者明確指示在 Buzz 頻道中進行多 Agent 協作任務
- **降級守衛（非 Buzz 環境）**：
  - 若在一般 IDE（VS Code、Antigravity IDE）或單機終端機 CLI（Claude Code、Codex）中對話，**嚴禁執行 Buzz CLI 指令**
  - 在非 Buzz 環境下，維持標準自然語言輸出即可，不可因未找到 Channel 或憑證而報錯

## 2. 核心通訊硬限制（Work in the Open）

在 Buzz 協作平台中，Agent 運行於 ACP（Agent Client Protocol）或類似 Harness 背後：

1. **不可隱匿結束回合**：
   - Agent 在內部產生的文字或思考，Buzz 頻道其他成員與 Owner **完全看不見**
   - 任何調查成果、代碼變更、審核判定（通過/需修改/阻擋）或問題阻礙，**禁止僅以內部文字結尾**
2. **必須調用 Buzz CLI 公開發布**：
   - 每次產出需要團隊知悉的結論時，必須調用工具執行 `buzz messages send` 指令發布至頻道：
     ```bash
     buzz messages send --channel "<CHANNEL_UUID>" --reply-to "<EVENT_ID>" --content "<回覆內容>"
     ```
   - 若內容包含多行文字，建議透過 stdin 傳遞換行以避免跳脫字元錯誤：
     ```bash
     printf '第一行\n\n第二行' | buzz messages send --channel "<CHANNEL_UUID>" --reply-to "<EVENT_ID>" --content -
     ```

## 3. 團隊協作流程與階級

多 Agent 團隊階級遵循清晰分工：
`Owner > Claude Lead > Codex Developer Reviewer > Gemini Junior > Hermes Agent`

1. **分派與執行**：
   - 高階（Lead）負責需求拆解與任務分派
   - 初階（Junior）或調查員（Hermes）負責範圍明確的唯讀查詢、文件整理或修改
2. **審查與向上回報**：
   - 低階完成任務後，必須向指定的審查者或最近上一階回報
   - 審查者核對後必須給出明確判定：`通過`、`需修改` 或 `阻擋`
   - `需修改` 時必須具體指出問題所在（如路徑錯誤、漏改檔案）並明確指示修正方式
   - 通過後依協作鏈向上回報，直到回報給 Owner
3. **Owner 知情原則**：
   - 所有回覆均應讓 Owner 看見進度，不可私下繞過 Owner 進行無記錄的操作

## 4. Mention 與 Threading 規範

1. **精確名稱**：
   - Mention 時使用精確名稱：`@Claude Lead`、`@Codex Developer Reviewer`、`@Gemini Junior`、`@Hermes Agent`
   - 不可在名稱內加斜線或其他非標準字元，以確保 Nostr 標籤正確解析
2. **同 Thread 延續**：
   - 回覆時一律在觸發該任務的同一個 Thread（使用傳入的 Event ID 或 Thread root）回覆，避免訊息散落
3. **無廢話確認**：
   - 禁止發送僅有「收到」、「確認」、「了解」的空洞訊息；只有產出實質成果、實質審查結果或阻礙時才發言

## 5. 邊界與安全底線

- 遵循 repo 根目錄 `AGENTS.md` 之所有硬限制
- 絕對禁止未經 Owner 明確授權執行任何 Salesforce deploy、validation 或 dry-run 指令
- 嚴格遵守語言規範：繁體中文、中英文不加空格、英文保留空格、不使用中文句點
