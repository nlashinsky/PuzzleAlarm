import Foundation

@Observable
class PatternPuzzleViewModel {
    let difficulty: Difficulty

    private(set) var pattern: [Int] = []
    private(set) var userInput: [Int] = []
    private(set) var isShowingPattern = true
    private(set) var currentShowIndex = 0
    private(set) var isCompleted = false
    private(set) var hasError = false

    let gridSize = 9 // 3x3 grid

    var patternLength: Int {
        difficulty.patternLength
    }

    var progress: String {
        "\(userInput.count)/\(patternLength)"
    }

    var instruction: String {
        if isShowingPattern {
            return "Watch the pattern..."
        } else if hasError {
            return "Wrong! Watch again..."
        } else {
            return "Repeat the pattern"
        }
    }

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        generatePattern()
    }

    func generatePattern() {
        pattern = (0..<patternLength).map { _ in
            Int.random(in: 0..<gridSize)
        }
        userInput = []
        hasError = false
        showPattern()
    }

    func showPattern() {
        isShowingPattern = true
        currentShowIndex = 0

        animatePattern()
    }

    private func animatePattern() {
        guard currentShowIndex < pattern.count else {
            // Done showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.isShowingPattern = false
                self?.currentShowIndex = -1
            }
            return
        }

        // Highlight current position
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            self.currentShowIndex += 1
            self.animatePattern()
        }
    }

    func tapCell(_ index: Int) {
        guard !isShowingPattern else { return }

        userInput.append(index)

        // Check if correct so far
        let currentIndex = userInput.count - 1
        if userInput[currentIndex] != pattern[currentIndex] {
            // Wrong!
            hasError = true
            userInput = []

            // Show pattern again after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showPattern()
            }
            return
        }

        // Check if complete
        if userInput.count == pattern.count {
            isCompleted = true
        }
    }

    func isHighlighted(_ index: Int) -> Bool {
        if isShowingPattern {
            return currentShowIndex < pattern.count && pattern[currentShowIndex] == index
        }
        return false
    }

    func wasSelected(_ index: Int) -> Bool {
        userInput.contains(index)
    }

    func reset() {
        generatePattern()
    }

    func clearInput() {
        userInput = []
    }
}
