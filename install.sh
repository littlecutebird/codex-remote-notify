#!/bin/sh
set -eu

label="com.longnguyen.codex-remote-notify"
domain="gui/$(id -u)"
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bin_dir="$HOME/.local/bin"
log_dir="$HOME/.codex/log"
agent_dir="$HOME/Library/LaunchAgents"
binary="$bin_dir/codex-remote-notify"
notifier_app="$HOME/.local/lib/codex-remote-notifier.app"
notifier="$notifier_app/Contents/MacOS/notifier"
notifier_info="$notifier_app/Contents/Info.plist"
plist="$agent_dir/$label.plist"
error_log="$log_dir/codex-remote-notify.err"
temporary=$(mktemp "${TMPDIR:-/tmp}/codex-remote-notify.XXXXXX")
trap 'rm -f "$temporary"' EXIT

mkdir -p "$bin_dir" "$log_dir" "$agent_dir" "$notifier_app/Contents/MacOS" "$notifier_app/Contents/Resources"
/usr/bin/install -m 755 "$source_dir/codex-remote-notify" "$binary"

/usr/bin/python3 - "$temporary" "$label" "$binary" "$error_log" "$notifier_info" <<'PY'
import plistlib
import sys

path, label, binary, error_log, notifier_info = sys.argv[1:]
with open(path, "wb") as output:
    plistlib.dump(
        {
            "Label": label,
            "ProgramArguments": [binary],
            "RunAtLoad": True,
            "KeepAlive": True,
            "ThrottleInterval": 5,
            "StandardErrorPath": error_log,
        },
        output,
    )
with open(notifier_info, "wb") as output:
    plistlib.dump(
        {
            "CFBundleDisplayName": "ChatGPT",
            "CFBundleExecutable": "notifier",
            "CFBundleIconFile": "AppIcon",
            "CFBundleIdentifier": "com.openai.codex",
            "CFBundleName": "ChatGPT",
            "CFBundlePackageType": "APPL",
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "LSUIElement": True,
        },
        output,
    )
PY

/usr/bin/swiftc "$source_dir/notifier.swift" -o "$notifier" -framework UserNotifications
/usr/bin/install -m 644 /Applications/ChatGPT.app/Contents/Resources/electron.icns "$notifier_app/Contents/Resources/AppIcon.icns"
/usr/bin/codesign --force --deep --sign - "$notifier_app" >/dev/null
/usr/bin/install -m 644 "$temporary" "$plist"
/usr/bin/plutil -lint "$plist" >/dev/null
/bin/launchctl bootout "$domain/$label" 2>/dev/null || true
/bin/launchctl bootstrap "$domain" "$plist"
/bin/launchctl kickstart -k "$domain/$label"
"$binary" --self-test

echo "Installed $label"
echo "Test it with: $binary --test"
echo "Check nodes with: $binary --check"
