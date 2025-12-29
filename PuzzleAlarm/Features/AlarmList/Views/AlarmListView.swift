import SwiftUI

struct AlarmListView: View {
    @Environment(AlarmStore.self) private var alarmStore
    @Environment(NotificationManager.self) private var notificationManager
    @State private var viewModel = AlarmListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if alarmStore.alarms.isEmpty {
                    emptyState
                } else {
                    alarmList
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: viewModel.createNewAlarm) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingEditor) {
                if let alarm = viewModel.selectedAlarm {
                    AlarmEditorView(alarm: alarm, isNew: alarmStore.alarm(for: alarm.id) == nil)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Alarms", systemImage: "alarm")
        } description: {
            Text("Tap + to create your first puzzle alarm")
        } actions: {
            Button("Create Alarm") {
                viewModel.createNewAlarm()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var alarmList: some View {
        List {
            ForEach(alarmStore.alarms) { alarm in
                AlarmRowView(
                    alarm: alarm,
                    viewModel: viewModel,
                    onToggle: { toggleAlarm(alarm) }
                )
            }
            .onDelete { offsets in
                deleteAlarms(at: offsets)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func toggleAlarm(_ alarm: Alarm) {
        alarmStore.toggle(alarm)

        if let updated = alarmStore.alarm(for: alarm.id) {
            Task {
                if updated.isEnabled {
                    await notificationManager.scheduleAlarm(updated)
                } else {
                    await notificationManager.cancelNotifications(for: updated.id)
                }
            }
        }
    }

    private func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            let alarm = alarmStore.alarms[index]
            notificationManager.cancelAllNotifications(for: alarm.id)
        }
        alarmStore.delete(at: offsets)
    }
}

struct AlarmRowView: View {
    let alarm: Alarm
    let viewModel: AlarmListViewModel
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.formatTime(alarm))
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundStyle(alarm.isEnabled ? .primary : .secondary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text(viewModel.formatPeriod(alarm))
                        .font(.title3)
                        .foregroundStyle(alarm.isEnabled ? .primary : .secondary)
                }

                HStack(spacing: 8) {
                    Text(alarm.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(viewModel.formatRepeatDays(alarm))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let nextText = viewModel.nextAlarmText(for: alarm) {
                    Text(nextText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.editAlarm(alarm)
        }
    }
}

#Preview {
    AlarmListView()
        .environment(AlarmStore())
        .environment(NotificationManager())
}
