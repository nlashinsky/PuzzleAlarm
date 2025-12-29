import Foundation

enum PuzzleType: String, CaseIterable, Codable, Identifiable {
    case math
    case memory
    case pattern
    case random

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .math: return "Math Problems"
        case .memory: return "Memory Game"
        case .pattern: return "Pattern Match"
        case .random: return "Random"
        }
    }

    var icon: String {
        switch self {
        case .math: return "function"
        case .memory: return "square.grid.3x3"
        case .pattern: return "circle.grid.3x3"
        case .random: return "shuffle"
        }
    }
}

struct Alarm: Identifiable, Codable, Equatable {
    let id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var label: String
    var repeatDays: Set<Weekday>
    var puzzleType: PuzzleType
    var difficulty: Difficulty
    var soundName: String

    init(
        id: UUID = UUID(),
        hour: Int = 7,
        minute: Int = 0,
        isEnabled: Bool = true,
        label: String = "Alarm",
        repeatDays: Set<Weekday> = [],
        puzzleType: PuzzleType = .random,
        difficulty: Difficulty = .medium,
        soundName: String = "default"
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.label = label
        self.repeatDays = repeatDays
        self.puzzleType = puzzleType
        self.difficulty = difficulty
        self.soundName = soundName
    }

    var timeString: String {
        String(format: "%d:%02d", hour, minute)
    }

    var dateComponents: DateComponents {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }

    var nextTriggerDate: Date? {
        let calendar = Calendar.current
        let now = Date()

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        if repeatDays.isEmpty {
            // One-time alarm - find next occurrence
            if let date = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) {
                return date
            }
        } else {
            // Repeating alarm - find next matching weekday
            var nearestDate: Date?
            for day in repeatDays {
                components.weekday = day.calendarWeekday
                if let date = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) {
                    if nearestDate == nil || date < nearestDate! {
                        nearestDate = date
                    }
                }
            }
            return nearestDate
        }

        return nil
    }
}

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var calendarWeekday: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var initial: String {
        String(shortName.prefix(1))
    }
}
