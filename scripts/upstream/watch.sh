#!/usr/bin/env bash
# Compare personal tools in upstream-watch.json against their upstream default branch.
# Change detection compares git tree SHAs of the watched paths at the pinned commit and
# at upstream HEAD, so it is not limited by the compare API's 300-file cap.
# For each tool prints one line: <name>\t<status>\t<report-file>
#   status: ahead (watched paths changed since pin) | current
# Requires gh (authenticated) and jq.
# Usage: scripts/upstream/watch.sh [out-dir]
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
OUT_DIR="${1:-${TMPDIR:-/tmp}/upstream-watch}"
mkdir -p "$OUT_DIR"

# entries <repo> <ref> <path>: "name<TAB>sha" for each entry under path ("" = repo root)
entries() {
  local repo="$1" ref="$2" path="${3%/}"
  if [ -z "$path" ]; then
    gh api "repos/$repo/contents?ref=$ref" --jq '.[] | .name + "\t" + .sha' 2>/dev/null || true
  else
    gh api "repos/$repo/contents/$path?ref=$ref" --jq ".[] | \"$path/\" + .name + \"\t\" + .sha" 2>/dev/null || true
  fi
}

for name in $(jq -r 'keys[]' upstream-watch.json); do
  repo="$(jq -r --arg n "$name" '.[$n].repo' upstream-watch.json)"
  pinned="$(jq -r --arg n "$name" '.[$n].pinned' upstream-watch.json)"
  installed="$(jq -r --arg n "$name" '.[$n].installed' upstream-watch.json)"
  update="$(jq -r --arg n "$name" '.[$n].update' upstream-watch.json)"

  branch="$(gh api "repos/$repo" --jq .default_branch)"
  head_sha="$(gh api "repos/$repo/commits/$branch" --jq .sha)"
  head_date="$(gh api "repos/$repo/commits/$branch" --jq .commit.committer.date | cut -c1-10)"
  pinned_date="$(gh api "repos/$repo/commits/$pinned" --jq .commit.committer.date)"

  changed=""
  for path in $(jq -r --arg n "$name" '.[$n].paths[] | if . == "" then "." else . end' upstream-watch.json); do
    [ "$path" = "." ] && path=""
    old="$(entries "$repo" "$pinned" "$path" | sort)"
    new="$(entries "$repo" "$head_sha" "$path" | sort)"
    diff_entries="$(comm -13 <(printf '%s\n' "$old") <(printf '%s\n' "$new") | cut -f1)"
    removed="$(comm -23 <(printf '%s\n' "$old" | cut -f1 | sort -u) <(printf '%s\n' "$new" | cut -f1 | sort -u) | sed 's/$/ (已移除)/')"
    changed="$(printf '%s\n%s\n%s' "$changed" "$diff_entries" "$removed" | sed '/^$/d')"
  done

  report="$OUT_DIR/$name.md"
  if [ -z "$changed" ]; then
    printf '%s\tcurrent\t%s\n' "$name" "$report"
    : > "$report"
    continue
  fi

  watched="$(jq -r --arg n "$name" '.[$n].paths | map(if . == "" then "(整個repo)" else . end) | join(",")' upstream-watch.json)"
  first_path="$(jq -r --arg n "$name" '.[$n].paths[0]' upstream-watch.json)"
  {
    echo "上游 [$repo](https://github.com/$repo) 的監看範圍($watched)在固定版本之後有變更"
    echo
    echo "| 項目 | 內容 |"
    echo "| --- | --- |"
    echo "| 固定版本 | \`${pinned:0:7}\` (${pinned_date:0:10}) |"
    echo "| 上游最新 | \`${head_sha:0:7}\` ($head_date) |"
    echo "| 上游最新tag | $(gh api "repos/$repo/tags?per_page=1" --jq '.[0].name // "(無)"') |"
    echo "| 本機安裝位置 | $installed |"
    echo
    echo "完整比對:https://github.com/$repo/compare/${pinned:0:7}...${head_sha:0:7}"
    echo
    echo "### 有變更的項目"
    printf '%s\n' "$changed" | sed 's/^/- `/; s/$/`/; s/ (已移除)`/` (已移除)/'
    echo
    echo "### 監看範圍內最近的commit"
    gh api "repos/$repo/commits?sha=$branch&since=$pinned_date&per_page=10${first_path:+&path=${first_path%/}}" \
      --jq '.[] | "- `\(.sha[0:7])` \(.commit.committer.date[0:10]) \(.commit.message | split("\n")[0])"'
    echo
    echo "### 決定升級時"
    echo '```bash'
    echo "$update"
    echo '```'
    echo "升級後把\`upstream-watch.json\`的\`$name.pinned\`改為新版本commit,此issue會在下次檢查時自動關閉"
    echo
    echo "此issue只做通知,不會自動更新本機工具"
  } > "$report"
  printf '%s\tahead\t%s\n' "$name" "$report"
done
