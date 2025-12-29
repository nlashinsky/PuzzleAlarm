import SwiftUI
import Combine

struct ActiveAlarmView: View {
    let alarm: Alarm
    let onDismiss: () -> Void

    @Environment(AudioManager.self) private var audioManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel: ActiveAlarmViewModel?
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.red.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Current time
                Text(currentTime, style: .time)
                    .font(.system(size: 64, weight: .light, design: .rounded))

                Text(alarm.label)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Divider()
                    .padding(.vertical)

                // Puzzle
                if let vm = viewModel {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: vm.puzzleType.icon)
                            Text(vm.puzzleType.displayName)
                        }
                        .font(.headline)
                        .foregroundStyle(.secondary)

                        Text("Solve to dismiss alarm")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    AnyPuzzleView(
                        puzzleType: vm.puzzleType,
                        difficulty: alarm.difficulty,
                        onComplete: {
                            vm.puzzleSolved()
                            onDismiss()
                        }
                    )
                }
            }
            .padding()
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            viewModel = ActiveAlarmViewModel(
                alarm: alarm,
                audioManager: audioManager,
                notificationManager: notificationManager
            )
        }
        .onReceive(timer) { time in
            currentTime = time
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel?.handleScenePhaseChange(newPhase)
        }
    }
}

#Preview {
    ActiveAlarmView(
        alarm: Alarm(
            hour: 7,
            minute: 30,
            label: "Wake up!",
            puzzleType: .math,
            difficulty: .medium
        )
    ) {
        print("Dismissed")
    }
    .environment(AudioManager())
    .environment(NotificationManager())
}
