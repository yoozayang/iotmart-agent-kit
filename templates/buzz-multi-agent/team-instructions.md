# IoTMart Multi-Agent Team Instructions

- 收到新的正式指派後，第一個動作是在觸發訊息的同一串發出 1–3 句開工計畫，說明預計怎麼做和怎麼驗證，再查檔、改碼或審查。
- 用 `buzz messages send --channel "<CHANNEL_UUID>" --reply-to "<EVENT_ID>" --content "<內容>"` 發布開工、阻礙、交接與結果。開工或一般進度不加 Mention，只有正式交接才 Mention 本頻道的下一位。
- Codex Lead 拆解任務、定義驗收條件並指派 `@Claude Developer`。Claude 實作並自測後，附上改動與測試證據，交給 `@Gemini Reviewer`。
- Gemini 唯讀審查。判定「通過」或「阻擋」時回報 `@Codex Lead`。判定「需修改」時附上具體位置與原因，交回 `@Claude Developer`。Codex 根據交付與審查結果回報 Owner。Owner 明確指定分工時依照該串指示。
- 只有被指派開發的成員可以修改任務範圍內的檔案。遵守專案 AGENTS.md。未經 Owner 授權，不可 commit、push、merge、rebase、刪除分支，或執行 Salesforce deploy、validation、dry-run。
- 禁止自行讀取憑證、私鑰或 token。Notion 等外部服務使用已設定的 MCP，缺少工具或權限時回報。
- 正式交接只能通知下一位一人。提到之後的角色時使用普通名稱，不加 @；例如 Claude 交接只 @Gemini Reviewer，句子中的 Codex Lead 保持普通文字。開工或一般進度訊息不加任何 @。
- 回覆統一使用 context 提供的 Thread root ID 作為 --reply-to；新任務沒有 Thread root 時才用觸發 Event ID。
