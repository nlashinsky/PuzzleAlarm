import SwiftUI

struct AlarmEditorView: View {
    @Environment(AlarmStore.self) private var alarmStore
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(\.dismiss) private var dismiss

    @State private var alarm: Alarm
    let isNew: Bool

    init(alarm: Alarm, isNew: Bool) {
        _alarm = State(initialValue: alarm)
        self.isNew = isNew
    }

    var body: some View {
        NavigationStack {
            Form {
                // Time picker
                Section {
                    DatePicker(
                        "Time",
                        selection: Binding(
                            get: { timeAsDate },
                            set: { updateTime(from: $0) }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }

                // Label
                Section("Label") {
                    TextField("Alarm", text: $alarm.label)
                }

                // Repeat days
                Section("Repeat") {
                    ForEach(Weekday.allCases) { day in
                        Toggle(day.shortName, isOn: Binding(
                            get: { alarm.repeatDays.contains(day) },
                            set: { isOn in
                                if isOn {
                                    alarm.repeatDays.insert(day)
                                } else {
                                    alarm.repeatDays.remove(day)
                                }
                            }
                        ))
                    }
                }

                // Puzzle type
                Section("Puzzle") {
                    Picker("Type", selection: $alarm.puzzleType) {
                        ForEach(PuzzleType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }

                    Picker("Difficulty", selection: $alarm.difficulty) {
                        ForEach(Difficulty.allCases) { difficulty in
                            Text(difficulty.displayName)
                                .tag(difficulty)
                        }
                    }
                }

                // Preview puzzle
                Section {
                    NavigationLink {
                        PuzzlePreviewView(puzzleType: alarm.puzzleType, difficulty: alarm.difficulty)
                    } label: {
                        Label("Preview Puzzle", systemImage: "eye")
                    }
                }

                // Delete (for existing alarms)
                if !isNew {
                    Section {
                        Button(role: .destructive) {
                            deleteAlarm()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Alarm")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAlarm()
                    }
                }
            }
        }
    }

    private var timeAsDate: Date {
        var components = DateComponents()
        components.hour = alarm.hour
        components.minute = alarm.minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private func updateTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        alarm.hour = components.hour ?? 0
        alarm.minute = components.minute ?? 0
    }

    private func saveAlarm() {
        if isNew {
            alarmStore.add(alarm)
        } else {
            alarmStore.update(alarm)
        }

        Task {
            if alarm.isEnabled {
                await notificationManager.scheduleAlarm(alarm)
            }
        }

        dismiss()
    }

    private func deleteAlarm() {
        notificationManager.cancelAllNotifications(for: alarm.id)
        alarmStore.delete(alarm)
        dismiss()
    }
}

struct PuzzlePreviewView: View {
    let puzzleType: PuzzleType
    let difficulty: Difficulty

    @Environment(\.dismiss) private var dismiss
    @State private var completed = false

    var body: some View {
        VStack {
            if completed {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)

                    Text("Puzzle Complete!")
                        .font(.title)

                    Button("Try Again") {
                        completed = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                AnyPuzzleView(
                    puzzleType: puzzleType == .random ? [.math, .memory, .pattern].randomElement()! : puzzleType,
                    difficulty: difficulty
                ) {
                    completed = true
                }
            }
        }
        .navigationTitle("Puzzle Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AlarmEditorView(alarm: Alarm(), isNew: true)
        .environment(AlarmStore())
        .environment(NotificationManager())
}
