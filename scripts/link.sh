#!/usr/bin/env bash
# Link iotmart-agent-kit into a project working tree so Codex, Claude Code and
# Gemini all read the same rules and skills.
#
# Usage:
#   scripts/link.sh <project-dir> [--replace] [--user-links]
#
#   --replace     Move existing real files/dirs (not symlinks) out of the project
#                 into ~/codex_tmp/agent-kit-backup/<timestamp>/ before linking.
#                 Without it the script stops when a real file is in the way.
#   --user-links  Also link own skills into ~/.agents/skills/ for other projects.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET=""
REPLACE=0
USER_LINKS=0
for arg in "$@"; do
  case "$arg" in
    --replace) REPLACE=1 ;;
    --user-links) USER_LINKS=1 ;;
    -*) echo "unknown option: $arg" >&2; exit 2 ;;
    *) TARGET="$arg" ;;
  esac
done
[ -n "$TARGET" ] || { echo "usage: scripts/link.sh <project-dir> [--replace] [--user-links]" >&2; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" != "$KIT" ] || { echo "target must not be the kit itself" >&2; exit 2; }

# Paths linked from the project root to the kit (same relative path on both sides).
ITEMS=(AGENTS.md CLAUDE.md GEMINI.md GIT_GUIDE.md skills-lock.json .mcp.json
       salesforce-mcp-config.json .codex .agents .gemini)
# Own skills also exposed at user level with --user-links.
OWN_SKILLS=(evidence-investigation-documentation)

BACKUP="$HOME/codex_tmp/agent-kit-backup/$(date +%Y%m%d-%H%M%S)"

# link <link-path> <link-target>
link() {
  local path="$1" dest="$2"
  if [ -L "$path" ]; then
    if [ "$(readlink "$path")" = "$dest" ]; then
      echo "ok      $path"
      return
    fi
    rm "$path"
  elif [ -e "$path" ]; then
    if [ "$REPLACE" -ne 1 ]; then
      echo "blocked $path exists as a real file/dir; rerun with --replace to back it up" >&2
      exit 1
    fi
    mkdir -p "$BACKUP"
    mv "$path" "$BACKUP/"
    echo "backup  $path -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$path")"
  ln -s "$dest" "$path"
  echo "linked  $path -> $dest"
}

# Pre-check every path first so a blocked item never leaves a half-linked project.
if [ "$REPLACE" -ne 1 ]; then
  for item in "${ITEMS[@]}" .claude/skills; do
    p="$TARGET/$item"
    if [ -e "$p" ] && [ ! -L "$p" ]; then
      echo "blocked $p exists as a real file/dir; rerun with --replace to back it up" >&2
      exit 1
    fi
  done
fi

for item in "${ITEMS[@]}"; do
  [ -e "$KIT/$item" ] || continue
  link "$TARGET/$item" "$KIT/$item"
done
# Claude Code discovers skills only under .claude/skills.
link "$TARGET/.claude/skills" "../.agents/skills"

# Keep the links out of the project's own git. Patterns without a trailing slash
# so they also match symlinks (a "dir/" pattern only matches real directories).
if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  EXCLUDE="$(git -C "$TARGET" rev-parse --git-path info/exclude)"
  case "$EXCLUDE" in /*) ;; *) EXCLUDE="$TARGET/$EXCLUDE" ;; esac
  mkdir -p "$(dirname "$EXCLUDE")"
  touch "$EXCLUDE"
  added=0
  for item in "${ITEMS[@]}" .claude/skills; do
    line="/$item"
    if ! grep -qxF "$line" "$EXCLUDE"; then
      [ "$added" -eq 1 ] || printf '\n# iotmart-agent-kit links\n' >> "$EXCLUDE"
      echo "$line" >> "$EXCLUDE"
      added=1
    fi
  done
  [ "$added" -eq 0 ] || echo "updated $EXCLUDE"
fi

if [ "$USER_LINKS" -eq 1 ]; then
  for skill in "${OWN_SKILLS[@]}"; do
    link "$HOME/.agents/skills/$skill" "$KIT/.agents/skills/$skill"
  done
fi

echo "done"
