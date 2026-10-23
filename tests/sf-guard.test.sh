#!/usr/bin/env bash
# Tests for bin/sf against a stub "real" sf, plus checks that the rule files agree with it.
# Usage: tests/sf-guard.test.sh   (no Salesforce org or network needed)
set -uo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Stub real sf: prod/uat resolve to Prod/sandbox URLs, other orgs are not logged in.
mkdir -p "$WORK/real" "$WORK/proj/force-app"
cat > "$WORK/real/sf" <<'EOF'
#!/usr/bin/env bash
if [ "$1 $2" = "org display" ]; then
  case "$4" in
    prod) echo '{"result":{"instanceUrl":"https://adv.my.salesforce.com"}}' ;;
    uat)  echo '{"result":{"instanceUrl":"https://adv--uat.sandbox.my.salesforce.com"}}' ;;
    *)    exit 1 ;;
  esac
  exit 0
fi
echo "REAL-SF: $*"
EOF
chmod +x "$WORK/real/sf"
export PATH="$KIT/bin:$WORK/real:$PATH"
cd "$WORK/proj"

fail=0
# expect <pass|block> <description> <sf args...>
expect() {
  local want="$1" desc="$2"; shift 2
  local out code
  out="$(sf "$@" 2>&1)"; code=$?
  if { [ "$want" = pass ] && [ "$code" -eq 0 ]; } || { [ "$want" = block ] && [ "$code" -eq 3 ]; }; then
    echo "ok    $desc"
  else
    echo "FAIL  $desc (exit $code): $out"; fail=1
  fi
}

expect block "prod deploy start without approval"              project deploy start -x p.xml -o prod
expect pass  "prod deploy start with --prod-approved <org>"    project deploy start -x p.xml -o prod --prod-approved prod
expect pass  "prod deploy start with --prod-approved=<org>"    project deploy start -x p.xml -o prod --prod-approved=prod
expect block "approval for another org does not count"         project deploy start -x p.xml -o prod --prod-approved uat
expect block "approval without a value does not count"         project deploy start -x p.xml -o prod --prod-approved
expect block "prod quick deploy without approval"              project deploy quick --job-id 0Af000 -o prod
expect pass  "prod quick deploy with approval"                 project deploy quick --job-id 0Af000 -o prod --prod-approved prod
expect pass  "prod validate needs no deploy approval"          project deploy validate -x p.xml -o prod
expect pass  "prod deploy start --dry-run is check-only"       project deploy start --dry-run -x p.xml -o prod
expect block "approved prod deploy of a directory"             project deploy start --source-dir force-app -o prod --prod-approved prod
expect block "approved prod deploy without scope"              project deploy start -o prod --prod-approved prod
expect block "approved prod deploy with --ignore-conflicts"    project deploy start -x p.xml --ignore-conflicts -o prod --prod-approved prod
expect block "approval does not unlock prod data writes"       data delete record -s Account -i 001 -o prod --prod-approved prod
expect block "approval does not unlock prod anonymous Apex"    apex run -f a.apex -o prod --prod-approved prod
expect block "approval does not unlock prod source delete"     project delete source -m ApexClass:A -o prod --prod-approved prod
expect pass  "sandbox deploy with manifest"                    project deploy start -x p.xml -o uat
expect block "sandbox directory deploy"                        project deploy start -d force-app -o uat
expect block "deploy without -o"                               project deploy start -x p.xml
expect block "org that cannot be resolved"                     project deploy start -x p.xml -o nobody
expect block "org delete"                                      org delete sandbox -o uat
expect pass  "read-only command passes through"                org list

out="$(SF_PROD_DEPLOY_APPROVED=YES sf project deploy start -x p.xml -o prod 2>&1)"
[ $? -eq 3 ] && echo "ok    old SF_PROD_DEPLOY_APPROVED env no longer approves" || { echo "FAIL  env approval still works: $out"; fail=1; }
out="$(sf project deploy start -x p.xml -o prod --prod-approved prod 2>&1)"
[ "$out" = "REAL-SF: project deploy start -x p.xml -o prod" ] && echo "ok    --prod-approved is not passed to the real sf" || { echo "FAIL  forwarded args: $out"; fail=1; }

# Rule files must not keep wording the guard no longer enforces.
stale='SF_PROD_DEPLOY_APPROVED|Prod只允許`deploy validate`|Prod allows only `deploy validate`|agent不可自行執行|agents must not run deployments|must remain`Validate Only|Prod一律Validate Only|Prod僅可做唯讀查詢'
if hits="$(cd "$KIT" && grep -rnE "$stale" AGENTS.md CLAUDE.md GEMINI.md GIT_GUIDE.md README.md README.zh-TW.md .codex .claude templates)"; then
  echo "FAIL  stale rule text:"; echo "$hits"; fail=1
else
  echo "ok    no stale Prod-deploy wording in rule files"
fi

# Codex rules: the approved form must still prompt (an env prefix would skip the prefix rule).
if command -v codex >/dev/null 2>&1; then
  for cmd in "sf project deploy start -x p.xml -o prod --prod-approved prod" "sf project deploy quick --job-id 0Af -o prod --prod-approved prod"; do
    # shellcheck disable=SC2086
    d="$(codex execpolicy check -r "$KIT/.codex/rules/sf-guard.rules" -- $cmd 2>/dev/null)"
    case "$d" in *'"decision":"prompt"'*) echo "ok    codex prompts: $cmd" ;; *) echo "FAIL  codex: $cmd -> $d"; fail=1 ;; esac
  done
  for cmd in "SF_GUARD_BYPASS=1 sf project deploy start -o prod" "env SF_GUARD_BYPASS=1 sf project deploy start -o prod"; do
    # shellcheck disable=SC2086
    d="$(codex execpolicy check -r "$KIT/.codex/rules/sf-guard.rules" -- $cmd 2>/dev/null)"
    case "$d" in *'"decision":"forbidden"'*) echo "ok    codex forbids: $cmd" ;; *) echo "FAIL  codex: $cmd -> $d"; fail=1 ;; esac
  done
else
  echo "skip  codex execpolicy checks (codex not installed)"
fi

[ "$fail" -eq 0 ] && echo "all passed" || { echo "FAILED"; exit 1; }
