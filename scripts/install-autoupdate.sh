#!/usr/bin/env bash
# Install (or remove) a macOS LaunchAgent that runs scripts/autoupdate.sh once a day:
# fast-forwards this kit and updates the personal tools in personal-tools.json.
# Local uncommitted or diverged work is never merged or reset.
#
# Usage:
#   scripts/install-autoupdate.sh            install / refresh (daily 09:30 local time)
#   scripts/install-autoupdate.sh --remove   uninstall
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
LABEL="com.$(id -un).iotmart-agent-kit.autoupdate"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/iotmart-agent-kit-autoupdate.log"
DOMAIN="gui/$(id -u)"

launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true

if [ "${1:-}" = "--remove" ]; then
  rm -f "$PLIST"
  echo "removed $LABEL"
  exit 0
fi

mkdir -p "$(dirname "$PLIST")" "$(dirname "$LOG")"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$KIT/scripts/autoupdate.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>30</integer></dict>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
EOF
plutil -lint "$PLIST" >/dev/null
launchctl bootstrap "$DOMAIN" "$PLIST"
echo "installed $LABEL (daily 09:30), log: $LOG"
echo "run now: launchctl kickstart $DOMAIN/$LABEL"
