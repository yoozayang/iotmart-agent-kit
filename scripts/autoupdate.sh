#!/usr/bin/env bash
# Daily local auto-update, run by the LaunchAgent from scripts/install-autoupdate.sh.
#   1. Fast-forward this kit from origin (merged upstream-update PRs reach every linked project).
#   2. Update personal tools listed in personal-tools.json:
#      - method "skills":  reinstall the listed skills at user level when upstream HEAD changes
#      - method "git-tag": check out the newest release tag of a local git clone
# Never merges or resets local work: a dirty or diverged checkout is skipped and reported.
# Results go to stdout (LaunchAgent log) and a macOS notification when something changed or failed.
set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

KIT="$(cd "$(dirname "$0")/.." && pwd)"
STATE="$HOME/.local/state/iotmart-agent-kit"
mkdir -p "$STATE"
changes=()
failures=()

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }
notify() {
  local msg="${1//\"/\'}"
  osascript -e "display notification \"$msg\" with title \"iotmart-agent-kit\"" >/dev/null 2>&1 || true
}

# 1. Kit
before="$(git -C "$KIT" rev-parse HEAD)"
if git -C "$KIT" pull --ff-only -q; then
  after="$(git -C "$KIT" rev-parse HEAD)"
  [ "$before" = "$after" ] || changes+=("kit ${before:0:7}->${after:0:7}")
else
  failures+=("kit pull(本機有未推送或分歧的修改)")
fi

# 2. Personal tools
for name in $(jq -r 'keys[]' "$KIT/personal-tools.json"); do
  cfg() { jq -r --arg n "$name" ".[\$n].$1" "$KIT/personal-tools.json"; }
  repo="$(cfg repo)"
  case "$(cfg method)" in
    skills)
      head="$(git ls-remote "https://github.com/$repo" HEAD 2>/dev/null | cut -f1)"
      if [ -z "$head" ]; then failures+=("$name:無法取得上游版本"); continue; fi
      last="$(cat "$STATE/$name.sha" 2>/dev/null || true)"
      [ "$head" != "$last" ] || continue
      args=()
      for s in $(jq -r --arg n "$name" '.[$n].skills[]' "$KIT/personal-tools.json"); do args+=(-s "$s"); done
      for a in $(jq -r --arg n "$name" '.[$n].agents[]' "$KIT/personal-tools.json"); do args+=(-a "$a"); done
      log "$name: installing upstream ${head:0:7}"
      if CI=true npx -y skills add "$repo" -g "${args[@]}" -y </dev/null; then
        echo "$head" > "$STATE/$name.sha"
        changes+=("$name->${head:0:7}")
      else
        failures+=("$name:安裝失敗")
      fi
      ;;
    git-tag)
      dir="$(cfg path)"; dir="${dir/#\~/$HOME}"
      if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
        failures+=("$name:本機有修改,略過"); continue
      fi
      git -C "$dir" fetch --tags -q 2>/dev/null || { failures+=("$name:fetch失敗"); continue; }
      latest="$(git -C "$dir" tag --sort=-v:refname | grep -E '^v?[0-9]+(\.[0-9]+)*$' | head -1)"
      current="$(git -C "$dir" describe --tags --exact-match 2>/dev/null || git -C "$dir" rev-parse --short HEAD)"
      [ -n "$latest" ] && [ "$latest" != "$current" ] || continue
      log "$name: $current -> $latest (rollback: git -C $dir checkout $current)"
      if git -C "$dir" checkout -q "$latest"; then
        changes+=("$name $current->$latest")
      else
        failures+=("$name:checkout $latest失敗")
      fi
      ;;
    *) failures+=("$name:未知method") ;;
  esac
done

[ "${#changes[@]}" -eq 0 ] || log "updated: ${changes[*]}"
[ "${#failures[@]}" -eq 0 ] || log "failed: ${failures[*]}"
[ "${#changes[@]}" -eq 0 ] && [ "${#failures[@]}" -eq 0 ] && log "no updates"

if [ "${#failures[@]}" -gt 0 ]; then
  notify "更新失敗:${failures[*]}"
elif [ "${#changes[@]}" -gt 0 ]; then
  notify "已更新:${changes[*]}"
fi
exit 0
