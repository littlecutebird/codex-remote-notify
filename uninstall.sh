#!/bin/sh
set -eu

label="com.longnguyen.codex-remote-notify"
domain="gui/$(id -u)"
plist="$HOME/Library/LaunchAgents/$label.plist"
binary="$HOME/.local/bin/codex-remote-notify"
notifier_app="$HOME/.local/lib/codex-remote-notifier.app"

/bin/launchctl bootout "$domain/$label" 2>/dev/null || true
rm -f "$plist" "$binary"
rm -rf "$notifier_app"
echo "Uninstalled $label (logs and last-notification state were kept)."
