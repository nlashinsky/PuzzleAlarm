import SwiftUI

@Observable
class ActiveAlarmViewModel {
    let alarm: Alarm

    private(set) var puzzleType: PuzzleType
    private(set) var isAlarmActive = true

    private let audioManager: AudioManager
    private let notificationManager: NotificationManager

    init(
        alarm: Alarm,
        audioManager: AudioManager = AudioManager(),
        notificationManager: NotificationManager = NotificationManager()
    ) {
        self.alarm = alarm
        self.audioManager = audioManager
        self.notificationManager = notificationManager

        // Resolve random puzzle type
        if alarm.puzzleType == .random {
            let types: [PuzzleType] = [.math, .memory, .pattern]
            self.puzzleType = types.randomElement() ?? .math
        } else {
            self.puzzleType = alarm.puzzleType
        }

        startAlarm()
    }

    private func startAlarm() {
        audioManager.configureAudioSession()
        audioManager.playAlarm(soundName: alarm.soundName)
    }

    func puzzleSolved() {
        isAlarmActive = false
        audioManager.stopAlarm()
        notificationManager.cancelAllNotifications(for: alarm.id)
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // User tried to leave - schedule reminder
            if isAlarmActive {
                Task {
                    await notificationManager.scheduleImmediateReminder(for: alarm.id)
                }
            }

        case .active:
            // User came back - ensure alarm is playing
            if isAlarmActive && !audioManager.isPlaying {
                audioManager.playAlarm(soundName: alarm.soundName)
            }

        case .inactive:
            break

        @unknown default:
            break
        }
    }
}
