import Foundation
import UserNotifications

guard CommandLine.arguments.count == 3 else { exit(2) }

let content = UNMutableNotificationContent()
content.title = CommandLine.arguments[1]
content.body = CommandLine.arguments[2]
let finished = DispatchSemaphore(value: 0)

UNUserNotificationCenter.current().add(
    UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
) { error in
    if let error {
        fputs("codex-remote-notifier: \(error)\n", stderr)
        exit(1)
    }
    finished.signal()
}

guard finished.wait(timeout: .now() + 5) == .success else { exit(1) }
