# Codex Remote Notify

Get a native macOS banner and the exact Codex turn-completion sound when a
Codex desktop task finishes on a remote SSH node.

Install once; the monitor automatically discovers every
`remote-ssh-discovered:*` node known to the Codex desktop app. Nothing is
installed on the remote nodes.

## Requirements

- macOS with the ChatGPT desktop app in `/Applications`
- Xcode Command Line Tools (for `swiftc`)
- Passwordless SSH aliases (`BatchMode=yes`) for the remote nodes
- Python 3 on the Mac and remote nodes
- At least one Codex desktop task opened on each remote node

## Install

```sh
cd /Users/longnguyen37/onemount/codex-remote-notify
./install.sh
```

Test the banner and sound:

```sh
~/.local/bin/codex-remote-notify --test
```

List discovered nodes and verify SSH access:

```sh
~/.local/bin/codex-remote-notify --list-hosts
~/.local/bin/codex-remote-notify --check
~/.local/bin/codex-remote-notify --check vu-mi350x8
```

The LaunchAgent runs at login and checks nodes every three seconds. One offline
node does not delay the others.

## Troubleshooting

```sh
launchctl print "gui/$(id -u)/com.longnguyen.codex-remote-notify"
tail -f ~/.codex/log/codex-remote-notify.err
cat ~/.codex/codex-remote-notify.last
```

If macOS asks, allow notifications for the app that displays the test banner.
Codex desktop notification controls are under **Settings > Notifications**.

## Uninstall

```sh
./uninstall.sh
```

The uninstaller keeps the error log and last-notification state for diagnosis.
