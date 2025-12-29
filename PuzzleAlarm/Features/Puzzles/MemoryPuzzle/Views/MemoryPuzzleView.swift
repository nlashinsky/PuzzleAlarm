import SwiftUI

struct MemoryPuzzleView: View {
    let difficulty: Difficulty
    let onComplete: () -> Void

    @State private var viewModel: MemoryPuzzleViewModel

    init(difficulty: Difficulty, onComplete: @escaping () -> Void) {
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = State(initialValue: MemoryPuzzleViewModel(difficulty: difficulty))
    }

    var columns: [GridItem] {
        let count = viewModel.cards.count
        let cols = count <= 6 ? 3 : (count <= 12 ? 4 : 4)
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: cols)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Progress
            Text("Matches: \(viewModel.progress)")
                .font(.headline)
                .foregroundStyle(.secondary)

            // Instructions
            Text("Find all matching pairs")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            // Card grid in ScrollView to ensure all cards visible
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                        MemoryCardView(card: card) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.flipCard(at: index)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                // Small delay for satisfaction
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

struct MemoryCardView: View {
    let card: MemoryCard
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isFaceUp || card.isMatched ? Color.white : Color.blue)
                    .shadow(radius: 2)

                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.blue.opacity(0.3), lineWidth: 2)

                if card.isFaceUp || card.isMatched {
                    Image(systemName: card.symbol)
                        .font(.system(size: 32))
                        .foregroundStyle(cardColor)
                }

                if card.isMatched {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.2))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .rotation3DEffect(
                .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .buttonStyle(.plain)
        .disabled(card.isMatched)
    }

    private var cardColor: Color {
        switch card.color {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "cyan": return .cyan
        default: return .primary
        }
    }
}

#Preview {
    MemoryPuzzleView(difficulty: .easy) {
        print("Completed!")
    }
}
