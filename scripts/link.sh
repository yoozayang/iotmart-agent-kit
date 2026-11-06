#!/usr/bin/env bash
# Link iotmart-agent-kit into a project working tree so Codex, Claude Code and
# Gemini all read the same rules and skills.
#
# Usage:
#   scripts/link.sh <project-dir> [--replace] [--user-links] [--all-worktrees] [--hook]
#
#   --replace        Move existing real files/dirs (not symlinks) out of the project
#                    into ~/codex_tmp/agent-kit-backup/<timestamp>/ before linking.
#                    Without it the script stops when a real file is in the way.
#   --user-links     Also link own skills into ~/.agents/skills/ for other projects.
#   --all-worktrees  Also link every other existing worktree of the project's repo.
#   --hook           Install a post-checkout hook in the project's repo so worktrees
#                    created later with "git worktree add" are linked automatically.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET=""
REPLACE=0
USER_LINKS=0
ALL_WORKTREES=0
HOOK=0
USAGE="usage: scripts/link.sh <project-dir> [--replace] [--user-links] [--all-worktrees] [--hook]"
for arg in "$@"; do
  case "$arg" in
    --replace) REPLACE=1 ;;
    --user-links) USER_LINKS=1 ;;
    --all-worktrees) ALL_WORKTREES=1 ;;
    --hook) HOOK=1 ;;
    -*) echo "unknown option: $arg" >&2; exit 2 ;;
    *) TARGET="$arg" ;;
  esac
done
[ -n "$TARGET" ] || { echo "$USAGE" >&2; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" != "$KIT" ] || { echo "target must not be the kit itself" >&2; exit 2; }

# Paths linked from the project root to the kit (same relative path on both sides).
ITEMS=(AGENTS.md CLAUDE.md GEMINI.md GIT_GUIDE.md skills-lock.json .mcp.json
       salesforce-mcp-config.json .codex .agents .gemini .claude/settings.json)
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

# link_project <working-tree>: link every item into one working tree.
link_project() {
  local dir="$1" item p
  # Pre-check every path first so a blocked item never leaves a half-linked tree.
  if [ "$REPLACE" -ne 1 ]; then
    for item in "${ITEMS[@]}" .claude/skills; do
      p="$dir/$item"
      if [ -e "$p" ] && [ ! -L "$p" ]; then
        echo "blocked $p exists as a real file/dir; rerun with --replace to back it up" >&2
        return 1
      fi
    done
  fi

  for item in "${ITEMS[@]}"; do
    [ -e "$KIT/$item" ] || continue
    link "$dir/$item" "$KIT/$item"
  done
  # Claude Code discovers skills only under .claude/skills.
  link "$dir/.claude/skills" "../.agents/skills"
}

TARGETS=("$TARGET")
if [ "$ALL_WORKTREES" -eq 1 ]; then
  # Worktrees whose directory no longer exists (prunable) are skipped.
  while IFS= read -r line; do
    case "$line" in
      "worktree "*)
        wt="${line#worktree }"
        if [ -d "$wt" ] && [ "$wt" != "$TARGET" ]; then TARGETS+=("$wt"); fi ;;
    esac
  done < <(git -C "$TARGET" worktree list --porcelain)
fi

FAILED=0
for dir in "${TARGETS[@]}"; do
  link_project "$dir" || FAILED=1
done

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

if [ "$HOOK" -eq 1 ]; then
  HOOKS_PATH="$(git -C "$TARGET" config --get core.hooksPath || true)"
  if [ -n "$HOOKS_PATH" ]; then
    echo "skipped hook: core.hooksPath is set to $HOOKS_PATH; add the kit hook there manually" >&2
    FAILED=1
  else
    HOOK_FILE="$(git -C "$TARGET" rev-parse --path-format=absolute --git-common-dir)/hooks/post-checkout"
    HOOK_MARK="# iotmart-agent-kit worktree link"
    if [ -e "$HOOK_FILE" ] && ! grep -qF "$HOOK_MARK" "$HOOK_FILE"; then
      echo "blocked $HOOK_FILE already exists; add the kit hook to it manually" >&2
      FAILED=1
    else
      mkdir -p "$(dirname "$HOOK_FILE")"
      # git worktree add runs post-checkout in the new worktree with an all-zero
      # previous HEAD; ordinary checkouts are left alone.
      cat > "$HOOK_FILE" <<EOF
#!/bin/sh
$HOOK_MARK
case "\$1" in *[!0]*) exit 0 ;; esac
[ -x "$KIT/scripts/link.sh" ] || exit 0
"$KIT/scripts/link.sh" "\$(pwd)" >/dev/null 2>&1 ||
  echo "iotmart-agent-kit: linking failed, run $KIT/scripts/link.sh \$(pwd)" >&2
exit 0
EOF
      chmod +x "$HOOK_FILE"
      echo "hooked  $HOOK_FILE"
    fi
  fi
fi

if [ "$USER_LINKS" -eq 1 ]; then
  for skill in "${OWN_SKILLS[@]}"; do
    link "$HOME/.agents/skills/$skill" "$KIT/.agents/skills/$skill"
  done
fi

[ "$FAILED" -eq 0 ] || exit 1
echo "done"
