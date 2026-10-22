# Buzz Multi-Agent Configuration Templates

本目錄收錄用於 Buzz 桌面端多 Agent 團隊協作的配置模板。

## 適用情境
- 本目錄為**選配模板**，一般開發者使用本 Kit 時無需安裝或設定 Buzz
- 當團隊希望建立由 Claude（Lead）、Codex（Reviewer/Developer）、Gemini（Junior）與 Hermes（Local Qwen 3.5 9B 調查員）組成的全自動化多階審核團隊時，可依本指南快速部署

## 目錄結構
- `team-instructions.md`: 全隊通用協作指示、階級定義與邊界規範
- `prompts/`: 各角色之專屬 System Prompt（已內建 Work in the open 與 `buzz messages send` 通訊硬限制）
  - `claude.md`: Claude Lead（任務統籌、規劃與分派）
  - `codex.md`: Codex Developer Reviewer（核心開發、獨立代碼審查）
  - `gemini.md`: Gemini Junior（初階開發、Hermes成果審查）

## 快速部署指南
將本目錄之設定複製至本機配置路徑：
```bash
mkdir -p ~/.config/buzz-multi-agent/prompts
cp templates/buzz-multi-agent/team-instructions.md ~/.config/buzz-multi-agent/
cp templates/buzz-multi-agent/prompts/*.md ~/.config/buzz-multi-agent/prompts/
```
搭配 `buzz-acp` 或相關 harness 啟動時，即可自動注入團隊角色與通訊規則。
