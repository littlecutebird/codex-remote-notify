#!/bin/sh
set -eu

label="com.longnguyen.codex-remote-notify"
domain="gui/$(id -u)"
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bin_dir="$HOME/.local/bin"
log_dir="$HOME/.codex/log"
agent_dir="$HOME/Library/LaunchAgents"
binary="$bin_dir/codex-remote-notify"
plist="$agent_dir/$label.plist"
error_log="$log_dir/codex-remote-notify.err"
temporary=$(mktemp "${TMPDIR:-/tmp}/codex-remote-notify.XXXXXX")
trap 'rm -f "$temporary"' EXIT

mkdir -p "$bin_dir" "$log_dir" "$agent_dir"
/usr/bin/install -m 755 "$source_dir/codex-remote-notify" "$binary"

/usr/bin/python3 - "$temporary" "$label" "$binary" "$error_log" <<'PY'
import plistlib
import sys

path, label, binary, error_log = sys.argv[1:]
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
PY

/usr/bin/install -m 644 "$temporary" "$plist"
/usr/bin/plutil -lint "$plist" >/dev/null
/bin/launchctl bootout "$domain/$label" 2>/dev/null || true
/bin/launchctl bootstrap "$domain" "$plist"
/bin/launchctl kickstart -k "$domain/$label"
"$binary" --self-test

echo "Installed $label"
echo "Test it with: $binary --test"
echo "Check nodes with: $binary --check"
