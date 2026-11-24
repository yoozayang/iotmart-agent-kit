# Buzz Multi-Agent Configuration Templates

本目錄收錄用於 Buzz 桌面端多 Agent 團隊協作的配置模板。

## 適用情境
- 本目錄為**選配模板**，一般開發者使用本 Kit 時無需安裝或設定 Buzz
- 團隊分工為 Codex Lead 指揮、Claude Developer 開發、Gemini Reviewer 唯讀審查

## 目錄結構
- `team-instructions.md`: 全隊通用協作指示、階級定義與邊界規範
- `base-prompt.md`: 以 Buzz 0.5.25 的基本規則為基礎，要求每次正式指派先在頻道發開工計畫
- `prompts/`: 各角色之專屬 System Prompt（已內建 Work in the open 與 `buzz messages send` 通訊硬限制）
  - `claude.md`: Claude Developer（實作、自測與交付）
  - `codex.md`: Codex Lead（規劃、派工與驗收）
  - `gemini.md`: Gemini Reviewer（唯讀審查與證據核對）

## 快速部署指南
將本目錄之設定複製至本機配置路徑：
```bash
mkdir -p ~/.config/buzz-multi-agent/prompts
cp templates/buzz-multi-agent/{base-prompt,team-instructions}.md ~/.config/buzz-multi-agent/
cp templates/buzz-multi-agent/prompts/*.md ~/.config/buzz-multi-agent/prompts/
```
在 Buzz Desktop 建立受管 Agent，角色提示加上共同規則。各角色的 Edit 介面可選接頭與模型。三個角色使用同一 Owner，Conversation context 選 Each thread。在 Advanced 的 Environment variables 將 `BUZZ_ACP_BASE_PROMPT_FILE` 指向本機 `base-prompt.md` 的絕對路徑，儲存後重新啟動 Agent。正式交接只 Mention 下一位，開工計畫在同串公開發出。
