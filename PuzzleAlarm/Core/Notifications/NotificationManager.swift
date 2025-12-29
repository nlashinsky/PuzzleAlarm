import Foundation
import UserNotifications

@Observable
class NotificationManager {
    private let center = UNUserNotificationCenter.current()

    var isAuthorized = false

    func requestAuthorization() {
        Task {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                await MainActor.run {
                    isAuthorized = granted
                }
            } catch {
                print("Notification authorization failed: \(error)")
            }
        }
    }

    func scheduleAlarm(_ alarm: Alarm) async {
        guard alarm.isEnabled else { return }

        // Cancel existing notifications for this alarm
        await cancelNotifications(for: alarm.id)

        let content = UNMutableNotificationContent()
        content.title = "Wake Up!"
        content.body = alarm.label.isEmpty ? "Time to solve your puzzle!" : alarm.label
        content.sound = UNNotificationSound(named: UNNotificationSoundName("\(alarm.soundName).caf"))
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.interruptionLevel = .timeSensitive
        content.userInfo = ["alarmId": alarm.id.uuidString]

        if alarm.repeatDays.isEmpty {
            // One-time alarm
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: alarm.dateComponents,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "\(alarm.id.uuidString)_0",
                content: content,
                trigger: trigger
            )

            try? await center.add(request)

            // Schedule backup notifications every 30 seconds for 5 minutes
            await scheduleBackupNotifications(for: alarm, baseContent: content)

        } else {
            // Repeating alarm - schedule for each day
            for day in alarm.repeatDays {
                var components = alarm.dateComponents
                components.weekday = day.calendarWeekday

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: true
                )

                let request = UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)_day\(day.rawValue)",
                    content: content,
                    trigger: trigger
                )

                try? await center.add(request)
            }
        }
    }

    private func scheduleBackupNotifications(for alarm: Alarm, baseContent: UNMutableNotificationContent) async {
        guard let triggerDate = alarm.nextTriggerDate else { return }

        // Schedule 10 backup notifications, 30 seconds apart
        for i in 1...10 {
            let backupDate = triggerDate.addingTimeInterval(TimeInterval(30 * i))
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: backupDate)

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            let content = baseContent.mutableCopy() as! UNMutableNotificationContent
            content.body = "Still time to wake up! Solve the puzzle."

            let request = UNNotificationRequest(
                identifier: "\(alarm.id.uuidString)_backup\(i)",
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    func scheduleImmediateReminder(for alarmId: UUID) async {
        let content = UNMutableNotificationContent()
        content.title = "Don't go back to sleep!"
        content.body = "You still need to solve the puzzle!"
        content.sound = .default
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(alarmId.uuidString)_reminder_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelNotifications(for alarmId: UUID) async {
        let pending = await center.pendingNotificationRequests()
        let idsToRemove = pending
            .filter { $0.identifier.hasPrefix(alarmId.uuidString) }
            .map(\.identifier)

        center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
    }

    func cancelAllNotifications(for alarmId: UUID) {
        Task {
            await cancelNotifications(for: alarmId)
        }
        center.removeDeliveredNotifications(withIdentifiers: [alarmId.uuidString])
    }
}
