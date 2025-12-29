import Foundation

@Observable
class AlarmListViewModel {
    var showingEditor = false
    var selectedAlarm: Alarm?

    func createNewAlarm() {
        selectedAlarm = Alarm()
        showingEditor = true
    }

    func editAlarm(_ alarm: Alarm) {
        selectedAlarm = alarm
        showingEditor = true
    }

    func formatTime(_ alarm: Alarm) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"

        var components = DateComponents()
        components.hour = alarm.hour
        components.minute = alarm.minute

        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return alarm.timeString
    }

    func formatPeriod(_ alarm: Alarm) -> String {
        alarm.hour >= 12 ? "PM" : "AM"
    }

    func formatRepeatDays(_ alarm: Alarm) -> String {
        if alarm.repeatDays.isEmpty {
            return "Once"
        }

        if alarm.repeatDays.count == 7 {
            return "Every day"
        }

        let weekdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        if alarm.repeatDays == weekdays {
            return "Weekdays"
        }

        let weekend: Set<Weekday> = [.saturday, .sunday]
        if alarm.repeatDays == weekend {
            return "Weekends"
        }

        return alarm.repeatDays
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.shortName)
            .joined(separator: ", ")
    }

    func nextAlarmText(for alarm: Alarm) -> String? {
        guard alarm.isEnabled, let nextDate = alarm.nextTriggerDate else { return nil }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Rings \(formatter.localizedString(for: nextDate, relativeTo: Date()))"
    }
}
