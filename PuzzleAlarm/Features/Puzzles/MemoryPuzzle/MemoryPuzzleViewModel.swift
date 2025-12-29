import Foundation

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let color: String
    var isFaceUp = false
    var isMatched = false
}

@Observable
class MemoryPuzzleViewModel {
    let difficulty: Difficulty

    private(set) var cards: [MemoryCard] = []
    private(set) var matchedPairs = 0
    private(set) var isCompleted = false

    private var firstFlippedIndex: Int?
    private var isProcessing = false

    var requiredPairs: Int {
        difficulty.memoryPairs
    }

    var progress: String {
        "\(matchedPairs)/\(requiredPairs)"
    }

    private let symbols = [
        ("star.fill", "yellow"),
        ("heart.fill", "red"),
        ("moon.fill", "purple"),
        ("sun.max.fill", "orange"),
        ("cloud.fill", "blue"),
        ("bolt.fill", "yellow"),
        ("leaf.fill", "green"),
        ("drop.fill", "cyan"),
        ("flame.fill", "orange"),
        ("snowflake", "blue"),
        ("sparkles", "purple"),
        ("bell.fill", "yellow")
    ]

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        generateCards()
    }

    func generateCards() {
        let selectedSymbols = Array(symbols.shuffled().prefix(requiredPairs))

        var newCards: [MemoryCard] = []
        for (symbol, color) in selectedSymbols {
            newCards.append(MemoryCard(symbol: symbol, color: color))
            newCards.append(MemoryCard(symbol: symbol, color: color))
        }

        cards = newCards.shuffled()
        matchedPairs = 0
        firstFlippedIndex = nil
        isCompleted = false
    }

    func flipCard(at index: Int) {
        guard !isProcessing,
              !cards[index].isMatched,
              !cards[index].isFaceUp else {
            return
        }

        cards[index].isFaceUp = true

        if let firstIndex = firstFlippedIndex {
            // Second card flipped
            isProcessing = true

            if cards[firstIndex].symbol == cards[index].symbol {
                // Match found!
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                matchedPairs += 1

                if matchedPairs >= requiredPairs {
                    isCompleted = true
                }

                firstFlippedIndex = nil
                isProcessing = false
            } else {
                // No match - flip back after delay
                let firstIdx = firstIndex
                let secondIdx = index

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.cards[firstIdx].isFaceUp = false
                    self?.cards[secondIdx].isFaceUp = false
                    self?.firstFlippedIndex = nil
                    self?.isProcessing = false
                }
            }
        } else {
            // First card flipped
            firstFlippedIndex = index
        }
    }

    func reset() {
        generateCards()
    }
}
