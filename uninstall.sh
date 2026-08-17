#!/bin/sh
set -eu

label="com.longnguyen.codex-remote-notify"
domain="gui/$(id -u)"
plist="$HOME/Library/LaunchAgents/$label.plist"
binary="$HOME/.local/bin/codex-remote-notify"

/bin/launchctl bootout "$domain/$label" 2>/dev/null || true
rm -f "$plist" "$binary"
echo "Uninstalled $label (logs and last-notification state were kept)."
