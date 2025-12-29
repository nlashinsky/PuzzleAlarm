import Foundation

enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy, medium, hard

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var mathProblemsRequired: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }

    var memoryPairs: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 8
        }
    }

    var patternLength: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 8
        }
    }
}
