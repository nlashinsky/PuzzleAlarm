import Foundation
import SwiftUI

@Observable
class AlarmStore {
    private static let storageKey = "com.puzzlealarm.alarms"

    var alarms: [Alarm] = [] {
        didSet {
            save()
        }
    }

    init() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([Alarm].self, from: data) else {
            alarms = []
            return
        }
        alarms = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(alarms) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
    }

    func update(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
        }
    }

    func delete(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
    }

    func delete(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }

    func toggle(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isEnabled.toggle()
        }
    }

    func alarm(for id: UUID) -> Alarm? {
        alarms.first { $0.id == id }
    }

    var enabledAlarms: [Alarm] {
        alarms.filter(\.isEnabled)
    }

    var nextAlarm: Alarm? {
        enabledAlarms
            .compactMap { alarm -> (Alarm, Date)? in
                guard let date = alarm.nextTriggerDate else { return nil }
                return (alarm, date)
            }
            .min { $0.1 < $1.1 }?
            .0
    }
}
