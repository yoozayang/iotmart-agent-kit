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
   - 收到正式指派後，先用 `buzz messages send` 在同一串發布 1–3 句開工計畫，再查檔、改碼或審查。說明預計怎麼做與怎麼驗證，開工訊息不加 Mention。
   - 發現阻礙、交接或完成時，使用同一指令發布：
     ```bash
     buzz messages send --channel "<CHANNEL_UUID>" --reply-to "<EVENT_ID>" --content "<回覆內容>"
     ```
   - 若內容包含多行文字，建議透過 stdin 傳遞換行以避免跳脫字元錯誤：
     ```bash
     printf '第一行\n\n第二行' | buzz messages send --channel "<CHANNEL_UUID>" --reply-to "<EVENT_ID>" --content -
     ```

## 3. 團隊協作流程

- **IoTMart｜Codex 指揮・Claude 開發**：Codex Lead 指揮與驗收，Claude Developer 實作與自測。
- **IoTMart｜Claude 指揮・Codex 開發**：Claude Lead 指揮與驗收，Codex Developer 實作與自測。
- 指揮者定義驗收條件、派工並向 Owner 回報。開發者完成後附上變更與測試證據，交回當串指揮者。
- Gemini Reviewer 依正式指派支援重現、調查、測試或唯讀審查，附上證據回報指揮者。指揮者派工時請 Gemini 先在原串發布獨立的開工計畫。
- Owner 在當串明確指定分工或回報對象時，依當串指示。

## 4. Mention 與 Threading 規範

1. **精確名稱**：
   - Mention 時使用本頻道成員的精確名稱：`@Codex Lead`、`@Claude Developer`、`@Claude Lead`、`@Codex Developer`、`@Gemini Reviewer`
   - 不可在名稱內加斜線或其他非標準字元，以確保 Nostr 標籤正確解析
2. **同 Thread 延續**：
   - 回覆時一律在觸發該任務的同一個 Thread（優先使用傳入的 Thread root，沒有時才用觸發 Event ID）回覆，避免訊息散落
3. **正式交接**：
   - 每次交接只 Mention 本頻道中負責下一步的一位成員。提及之後的角色時使用普通名稱，不加 @，避免提前觸發。收到開工或一般進度訊息時，等正式交接再接手。

## 5. 邊界與安全底線

- 遵循 repo 根目錄 `AGENTS.md` 之所有硬限制
- 絕對禁止未經 Owner 明確授權執行任何 Salesforce deploy、validation 或 dry-run 指令
- 嚴格遵守語言規範：繁體中文、中英文不加空格、英文保留空格、不使用中文句點
