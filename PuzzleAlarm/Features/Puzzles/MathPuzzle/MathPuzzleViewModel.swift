import Foundation

@Observable
class MathPuzzleViewModel {
    let difficulty: Difficulty

    private(set) var expression: String = ""
    private(set) var correctAnswer: Int = 0
    private(set) var solvedCount: Int = 0
    private(set) var isCompleted: Bool = false

    var userInput: String = ""

    var requiredSolves: Int {
        difficulty.mathProblemsRequired
    }

    var progress: String {
        "\(solvedCount)/\(requiredSolves)"
    }

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        generateProblem()
    }

    func generateProblem() {
        userInput = ""

        switch difficulty {
        case .easy:
            generateEasyProblem()
        case .medium:
            generateMediumProblem()
        case .hard:
            generateHardProblem()
        }
    }

    private func generateEasyProblem() {
        let a = Int.random(in: 1...20)
        let b = Int.random(in: 1...20)
        let isAddition = Bool.random()

        if isAddition {
            expression = "\(a) + \(b)"
            correctAnswer = a + b
        } else {
            // Ensure non-negative result
            let larger = max(a, b)
            let smaller = min(a, b)
            expression = "\(larger) - \(smaller)"
            correctAnswer = larger - smaller
        }
    }

    private func generateMediumProblem() {
        let a = Int.random(in: 1...12)
        let b = Int.random(in: 1...12)
        let c = Int.random(in: 1...10)

        let type = Int.random(in: 0...2)

        switch type {
        case 0:
            // Multiplication
            expression = "\(a) × \(b)"
            correctAnswer = a * b
        case 1:
            // Addition then multiplication (showing order of operations)
            expression = "\(a) + \(b) × \(c)"
            correctAnswer = a + (b * c)
        default:
            // Two additions
            expression = "\(a) + \(b) + \(c)"
            correctAnswer = a + b + c
        }
    }

    private func generateHardProblem() {
        let a = Int.random(in: 5...15)
        let b = Int.random(in: 5...15)
        let c = Int.random(in: 2...5)
        let d = Int.random(in: 1...20)

        let type = Int.random(in: 0...2)

        switch type {
        case 0:
            // Parentheses with multiplication
            expression = "(\(a) + \(b)) × \(c)"
            correctAnswer = (a + b) * c
        case 1:
            // Full expression
            expression = "(\(a) + \(b)) × \(c) - \(d)"
            correctAnswer = (a + b) * c - d
        default:
            // Division (ensure clean division)
            let divisor = Int.random(in: 2...9)
            let quotient = Int.random(in: 2...12)
            let dividend = divisor * quotient
            expression = "\(dividend) ÷ \(divisor) + \(a)"
            correctAnswer = quotient + a
        }
    }

    func checkAnswer() -> Bool {
        guard let answer = Int(userInput.trimmingCharacters(in: .whitespaces)) else {
            return false
        }

        if answer == correctAnswer {
            solvedCount += 1
            if solvedCount >= requiredSolves {
                isCompleted = true
            } else {
                generateProblem()
            }
            return true
        }

        return false
    }

    func reset() {
        solvedCount = 0
        isCompleted = false
        generateProblem()
    }
}
