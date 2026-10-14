#!/bin/bash
# IoTMart Agent Kit installer (macOS / Linux, bash 3.2+).
# Copies the kit into a project and/or the user home. No git or symlinks needed.
# Started by install-mac.command; safe to run again to update (changed files are backed up first).
#
#   --project <dir>   install rules + skills into this project (skips the folder dialog)
#   --skills-only     install skills to the user home only
#   --yes             no questions, no pause (for testing); the sf guard PATH step is skipped
set -u

KIT="$(cd "$(dirname "$0")/.." && pwd)"
USER_HOME="${IOTMART_KIT_HOME:-$HOME}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$USER_HOME/.iotmart-agent-kit-backup/$STAMP"
PROJECT=""
SKILLS_ONLY=0
YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2:-}"; shift 2 ;;
    --skills-only) SKILLS_ONLY=1; shift ;;
    --yes) YES=1; shift ;;
    *) shift ;;
  esac
done

INSTALLED=(); KEPT=(); BACKED=(); NOTES=()
c() { printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
say() { echo "$*"; }
finish() {
  [ "$YES" -eq 1 ] || { printf '按 Enter 關閉視窗'; read -r _; }
  exit "$1"
}

tree_hash() {
  if [ -f "$1" ]; then shasum -a 256 "$1" | cut -d' ' -f1; return; fi
  (cd "$1" && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 shasum -a 256) | shasum -a 256 | cut -d' ' -f1
}

backup_path() {
  case "$1" in
    "~/"*) echo "$BACKUP/home/${1#\~/}" ;;
    *) echo "$BACKUP/project/$1" ;;
  esac
}

# install_copy <src> <dst> <label>: move existing content to the backup, skip if identical
install_copy() {
  local src="$1" dst="$2" label="$3" bk
  [ -e "$src" ] || return 0
  if [ -L "$dst" ]; then KEPT+=("$label (是連結,維持原樣)"); return 0; fi
  if [ -e "$dst" ]; then
    if [ "$(tree_hash "$src")" = "$(tree_hash "$dst")" ]; then KEPT+=("$label (已是最新)"); return 0; fi
    bk="$(backup_path "$label")"
    mkdir -p "$(dirname "$bk")"
    if ! mv "$dst" "$bk"; then NOTES+=("$label 無法備份,未更新"); return 0; fi
    BACKED+=("$label")
  fi
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
  INSTALLED+=("$label")
}

# install_if_missing <src> <dst> <label>: personal settings are never overwritten
install_if_missing() {
  local src="$1" dst="$2" label="$3"
  [ -e "$src" ] || return 0
  if [ -e "$dst" ] || [ -L "$dst" ]; then KEPT+=("$label (已存在,保留你的設定)"); return 0; fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  INSTALLED+=("$label")
}

# merge_claude_settings <src> <dst> <label>: keep existing settings, add the kit's ask/deny rules
merge_claude_settings() {
  local src="$1" dst="$2" label="$3" merged bk
  if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then install_if_missing "$src" "$dst" "$label"; return 0; fi
  if [ -L "$dst" ]; then KEPT+=("$label (是連結,維持原樣)"); return 0; fi
  if ! command -v jq >/dev/null 2>&1 || ! merged="$(jq -s '
      .[0] as $cur | .[1] as $kit
      | $cur * {permissions: (($cur.permissions // {}) + {
          ask:  ((($cur.permissions.ask  // []) + ($kit.permissions.ask  // [])) | unique),
          deny: ((($cur.permissions.deny // []) + ($kit.permissions.deny // [])) | unique)})}' "$dst" "$src" 2>/dev/null)"; then
    cp "$src" "$(dirname "$dst")/settings.iotmart.json"
    NOTES+=("$label 無法自動合併;kit的權限設定另存為 settings.iotmart.json,請手動合併")
    return 0
  fi
  if [ "$(printf '%s' "$merged" | jq -S .)" = "$(jq -S . "$dst")" ]; then KEPT+=("$label (權限已包含kit規則)"); return 0; fi
  bk="$(backup_path "$label")"
  mkdir -p "$(dirname "$bk")" && cp "$dst" "$bk" && BACKED+=("$label")
  printf '%s\n' "$merged" > "$dst"
  INSTALLED+=("$label (合併kit權限)")
}

add_git_exclude() {
  local project="$1"; shift
  [ -d "$project/.git" ] || return 0
  local exclude="$project/.git/info/exclude" added=0 e
  mkdir -p "$(dirname "$exclude")"; touch "$exclude"
  for e in "$@"; do
    if ! grep -qxF "$e" "$exclude"; then
      [ "$added" -eq 1 ] || printf '\n# iotmart-agent-kit\n' >> "$exclude"
      echo "$e" >> "$exclude"; added=1
    fi
  done
  [ "$added" -eq 0 ] || INSTALLED+=(".git/info/exclude (避免把agent檔案commit進公司repo)")
}

# ---------------------------------------------------------------------------

# Files from a downloaded zip carry the quarantine flag; clear it inside the kit only.
command -v xattr >/dev/null 2>&1 && xattr -dr com.apple.quarantine "$KIT" 2>/dev/null

if [ ! -f "$KIT/AGENTS.md" ]; then
  c 31 '找不到 AGENTS.md:請先把整個 zip 解壓縮,再執行資料夾裡的安裝檔'
  finish 1
fi

echo
c 36 '=== IoTMart Agent Kit 安裝 ==='
say "來源:$KIT"
echo

if [ -z "$PROJECT" ] && [ "$SKILLS_ONLY" -eq 0 ]; then
  say '接下來會跳出「選擇資料夾」視窗:'
  say '  - 請選你的 IoTMart 專案資料夾(裡面有 sfdx-project.json 的那一層)'
  say '  - 按「取消」= 只安裝 skill,不放專案規則'
  echo
  if command -v osascript >/dev/null 2>&1; then
    PROJECT="$(osascript -e 'POSIX path of (choose folder with prompt "選擇 IoTMart 專案資料夾(取消 = 只安裝 skill)")' 2>/dev/null || true)"
  else
    printf '輸入專案資料夾路徑(直接 Enter = 只安裝 skill):'; read -r PROJECT
  fi
  PROJECT="${PROJECT%/}"
fi

if [ -n "$PROJECT" ]; then
  if [ ! -d "$PROJECT" ]; then c 31 "資料夾不存在:$PROJECT"; finish 1; fi
  PROJECT="$(cd "$PROJECT" && pwd)"
  if [ "$PROJECT" = "$KIT" ]; then c 31 '選到的是 kit 本身,請改選你的專案資料夾'; finish 1; fi
  if [ ! -f "$PROJECT/sfdx-project.json" ]; then
    c 33 "這個資料夾裡沒有 sfdx-project.json,看起來不是 IoTMart 專案:$PROJECT"
    if [ "$YES" -eq 0 ]; then
      printf '仍要安裝到這裡嗎?輸入 Y 繼續,其他鍵取消:'; read -r ans
      case "$ans" in [Yy]*) ;; *) say '已取消'; finish 1 ;; esac
    fi
  fi
  c 36 "安裝到專案:$PROJECT"

  for f in AGENTS.md CLAUDE.md GEMINI.md GIT_GUIDE.md skills-lock.json salesforce-mcp-config.json; do
    install_copy "$KIT/$f" "$PROJECT/$f" "$f"
  done
  for d in routing.md knowledge playbooks skills rules; do
    install_copy "$KIT/.codex/$d" "$PROJECT/.codex/$d" ".codex/$d"
  done
  install_if_missing "$KIT/.codex/config.toml" "$PROJECT/.codex/config.toml" ".codex/config.toml"
  install_copy "$KIT/.gemini/styleguide.md" "$PROJECT/.gemini/styleguide.md" ".gemini/styleguide.md"
  install_if_missing "$KIT/.gemini/settings.json" "$PROJECT/.gemini/settings.json" ".gemini/settings.json"
  for s in "$KIT"/.agents/skills/*/; do
    s="${s%/}"; n="$(basename "$s")"
    install_copy "$s" "$PROJECT/.agents/skills/$n" ".agents/skills/$n"
    install_copy "$s" "$PROJECT/.claude/skills/$n" ".claude/skills/$n"
  done
  merge_claude_settings "$KIT/.claude/settings.json" "$PROJECT/.claude/settings.json" ".claude/settings.json"
  add_git_exclude "$PROJECT" /AGENTS.md /CLAUDE.md /GEMINI.md /GIT_GUIDE.md /skills-lock.json \
    /salesforce-mcp-config.json /.codex /.agents /.gemini /.claude/skills /.claude/settings.json
else
  c 36 '只安裝 skill 到使用者資料夾(所有專案都能用)'
  for s in "$KIT"/.agents/skills/*/; do
    s="${s%/}"; n="$(basename "$s")"
    install_copy "$s" "$USER_HOME/.agents/skills/$n" "~/.agents/skills/$n"
    install_copy "$s" "$USER_HOME/.claude/skills/$n" "~/.claude/skills/$n"
  done
  NOTES+=("只裝了 skill:專案規則(AGENTS.md 等)與 sf-skills-overlay.md 沒有安裝;要完整功能請重新執行並選專案資料夾")
fi

# Codex execution rules apply to every project, so they go to the user home in both modes.
install_copy "$KIT/.codex/rules/sf-guard.rules" "$USER_HOME/.codex/rules/iotmart-sf-guard.rules" "~/.codex/rules/iotmart-sf-guard.rules"

# sf guard wrapper: copy to the user home and put it first on PATH (asks first).
MARK="# iotmart-agent-kit sf guard"
GUARD_BIN="$USER_HOME/.iotmart-agent-kit/bin"
if grep -qsF "$MARK" "$USER_HOME/.zshrc" "$USER_HOME/.zprofile" "$USER_HOME/.bash_profile"; then
  KEPT+=("sf 防護 (shell 設定已存在)")
  [ -d "$GUARD_BIN" ] && install_copy "$KIT/bin" "$GUARD_BIN" "~/.iotmart-agent-kit/bin"
elif [ "$YES" -eq 0 ]; then
  echo
  say '要安裝 sf 指令防護嗎?(擋 Prod 部署、全量部署、未指定 org 等危險操作)'
  printf '建議安裝,直接 Enter = 安裝,輸入 N = 略過:'; read -r ans
  case "$ans" in
    [Nn]*) NOTES+=("未安裝 sf 指令防護;之後可重新執行安裝檔加裝") ;;
    *)
      install_copy "$KIT/bin" "$GUARD_BIN" "~/.iotmart-agent-kit/bin"
      chmod +x "$GUARD_BIN"/* 2>/dev/null
      line="[ -d \"\$HOME/.iotmart-agent-kit/bin\" ] && export PATH=\"\$HOME/.iotmart-agent-kit/bin:\$PATH\"  $MARK"
      for rc in .zshrc .zprofile .bash_profile; do
        printf '\n%s\n' "$line" >> "$USER_HOME/$rc"
      done
      INSTALLED+=("sf 指令防護(~/.zshrc,~/.zprofile,~/.bash_profile 加入 PATH)")
      ;;
  esac
fi

echo
c 32 '=== 安裝完成 ==='
if [ "${#INSTALLED[@]}" -gt 0 ]; then c 32 "已安裝或更新(${#INSTALLED[@]}):"; for x in "${INSTALLED[@]}"; do say "  + $x"; done; fi
if [ "${#KEPT[@]}" -gt 0 ]; then say "未變動(${#KEPT[@]}):"; for x in "${KEPT[@]}"; do say "  = $x"; done; fi
if [ "${#BACKED[@]}" -gt 0 ]; then c 33 "舊檔已備份到:$BACKUP"; fi
if [ "${#NOTES[@]}" -gt 0 ]; then c 33 '注意:'; for x in "${NOTES[@]}"; do c 33 "  ! $x"; done; fi
echo
c 36 '請重新開啟終端機、Codex / Claude Code / Gemini 讓設定生效'
finish 0
