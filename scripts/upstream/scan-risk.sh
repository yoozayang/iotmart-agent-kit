#!/usr/bin/env bash
# Scan lines ADDED to official skills (vs HEAD) for patterns the overlay must cover.
# Prints a Markdown report to stdout. Large JSON context assets are skipped.
# Usage: scripts/upstream/scan-risk.sh [base-ref]
set -euo pipefail
BASE="${1:-HEAD}"
cd "$(git rev-parse --show-toplevel)"

added="$(git diff -U0 "$BASE" -- .agents/skills ':(exclude)*.json' | grep -E '^\+[^+]' || true)"

# label|regex
PATTERNS=(
  "目錄或全量部署(--source-dir/-d force-app)|(--source-dir|-d)[ =]+force-app"
  "--ignore-conflicts|--ignore-conflicts"
  "deploy start|project deploy start|deploy metadata"
  "Quick Deploy|deploy quick|quick deploy"
  "資料寫入|data (delete|update|upsert|import|create)"
  "匿名Apex|apex run( |$)(-|--file|-f)"
  "刪除org|org delete"
  "sfdx|(^|[^a-z-])sfdx "
  "預設org|default (target )?org|uses default"
  "MCP使用規則|NEVER use MCP|MCP tool"
)

echo "### 新增內容風險掃描"
echo
if [ -z "$added" ]; then
  echo "沒有新增內容(不含JSON資產)"
  exit 0
fi
echo "| 檢查項目 | 新增行數 | 範例 |"
echo "| --- | --- | --- |"
hits=0
for p in "${PATTERNS[@]}"; do
  label="${p%%|*}"; regex="${p#*|}"
  matched="$(printf '%s\n' "$added" | grep -iE -- "$regex" || true)"
  if [ -n "$matched" ]; then
    n="$(printf '%s\n' "$matched" | wc -l | tr -d ' ')"
    sample="$(printf '%s\n' "$matched" | head -1 | cut -c2-140 | sed 's/|/\\|/g; s/`/\\`/g')"
    echo "| $label | $n | \`$sample\` |"
    hits=$((hits + n))
  fi
done
[ "$hits" -gt 0 ] || echo "| (無命中) | 0 | |"
echo
echo "命中項目需對照\`.codex/playbooks/sf-skills-overlay.md\`,確認overlay仍有覆寫"
