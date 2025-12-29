import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
        return true
    }

    private func registerNotificationCategories() {
        let solveAction = UNNotificationAction(
            identifier: "SOLVE_PUZZLE",
            title: "Solve Puzzle",
            options: [.foreground]
        )

        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [solveAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }

    // Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let alarmIdString = notification.request.identifier.components(separatedBy: "_").first ?? ""
        if let alarmId = UUID(uuidString: alarmIdString) {
            NotificationCenter.default.post(
                name: .alarmTriggered,
                object: nil,
                userInfo: ["alarmId": alarmId]
            )
        }

        completionHandler([.sound, .banner])
    }

    // Called when user interacts with notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let alarmIdString = response.notification.request.identifier.components(separatedBy: "_").first ?? ""

        switch response.actionIdentifier {
        case "SOLVE_PUZZLE", UNNotificationDefaultActionIdentifier:
            if let alarmId = UUID(uuidString: alarmIdString) {
                NotificationCenter.default.post(
                    name: .alarmTriggered,
                    object: nil,
                    userInfo: ["alarmId": alarmId]
                )
            }

        case UNNotificationDismissActionIdentifier:
            // User dismissed - we can't prevent this, but schedule immediate follow-up
            if let alarmId = UUID(uuidString: alarmIdString) {
                Task {
                    await NotificationManager().scheduleImmediateReminder(for: alarmId)
                }
            }

        default:
            break
        }

        completionHandler()
    }
}
