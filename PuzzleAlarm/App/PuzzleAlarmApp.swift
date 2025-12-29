import SwiftUI

@main
struct PuzzleAlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var alarmStore = AlarmStore()
    @State private var notificationManager = NotificationManager()
    @State private var audioManager = AudioManager()
    @State private var activeAlarmId: UUID?

    var body: some Scene {
        WindowGroup {
            ContentView(activeAlarmId: $activeAlarmId)
                .environment(alarmStore)
                .environment(notificationManager)
                .environment(audioManager)
                .onAppear {
                    notificationManager.requestAuthorization()
                    audioManager.configureAudioSession()
                    scheduleAllAlarms()
                }
                .onReceive(NotificationCenter.default.publisher(for: .alarmTriggered)) { notification in
                    if let alarmId = notification.userInfo?["alarmId"] as? UUID {
                        activeAlarmId = alarmId
                    }
                }
        }
    }

    private func scheduleAllAlarms() {
        Task {
            for alarm in alarmStore.enabledAlarms {
                await notificationManager.scheduleAlarm(alarm)
            }
        }
    }
}

struct ContentView: View {
    @Environment(AlarmStore.self) private var alarmStore
    @Binding var activeAlarmId: UUID?

    var body: some View {
        ZStack {
            AlarmListView()

            if let alarmId = activeAlarmId,
               let alarm = alarmStore.alarm(for: alarmId) {
                ActiveAlarmView(alarm: alarm) {
                    activeAlarmId = nil
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: activeAlarmId)
    }
}

extension Notification.Name {
    static let alarmTriggered = Notification.Name("alarmTriggered")
}
