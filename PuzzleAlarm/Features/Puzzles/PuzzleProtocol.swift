import SwiftUI

protocol Puzzle: Identifiable {
    var id: UUID { get }
    var difficulty: Difficulty { get }
    var isCompleted: Bool { get }

    mutating func reset()
}

struct AnyPuzzleView: View {
    let puzzleType: PuzzleType
    let difficulty: Difficulty
    let onComplete: () -> Void

    var body: some View {
        switch puzzleType {
        case .math:
            MathPuzzleView(difficulty: difficulty, onComplete: onComplete)
        case .memory:
            MemoryPuzzleView(difficulty: difficulty, onComplete: onComplete)
        case .pattern:
            PatternPuzzleView(difficulty: difficulty, onComplete: onComplete)
        case .random:
            RandomPuzzleView(difficulty: difficulty, onComplete: onComplete)
        }
    }
}

struct RandomPuzzleView: View {
    let difficulty: Difficulty
    let onComplete: () -> Void

    @State private var selectedType: PuzzleType

    init(difficulty: Difficulty, onComplete: @escaping () -> Void) {
        self.difficulty = difficulty
        self.onComplete = onComplete

        let types: [PuzzleType] = [.math, .memory, .pattern]
        _selectedType = State(initialValue: types.randomElement() ?? .math)
    }

    var body: some View {
        AnyPuzzleView(puzzleType: selectedType, difficulty: difficulty, onComplete: onComplete)
    }
}
