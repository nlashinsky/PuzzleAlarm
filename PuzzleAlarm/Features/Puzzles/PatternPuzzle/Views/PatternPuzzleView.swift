import SwiftUI

struct PatternPuzzleView: View {
    let difficulty: Difficulty
    let onComplete: () -> Void

    @State private var viewModel: PatternPuzzleViewModel

    init(difficulty: Difficulty, onComplete: @escaping () -> Void) {
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = State(initialValue: PatternPuzzleViewModel(difficulty: difficulty))
    }

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 24) {
            // Progress
            if !viewModel.isShowingPattern {
                Text("Progress: \(viewModel.progress)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Instructions
            Text(viewModel.instruction)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(viewModel.hasError ? .red : .primary)
                .animation(.easeInOut, value: viewModel.instruction)

            // Pattern grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<viewModel.gridSize, id: \.self) { index in
                    PatternCellView(
                        index: index,
                        isHighlighted: viewModel.isHighlighted(index),
                        wasSelected: viewModel.wasSelected(index),
                        isShowingPattern: viewModel.isShowingPattern
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.tapCell(index)
                        }

                        // Haptic
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
            .padding()
            .disabled(viewModel.isShowingPattern)

            // Replay button (only when not showing)
            if !viewModel.isShowingPattern && !viewModel.isCompleted {
                Button(action: {
                    viewModel.clearInput()
                    viewModel.showPattern()
                }) {
                    Label("Show Pattern Again", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                // Success haptic
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
        .onChange(of: viewModel.hasError) { _, hasError in
            if hasError {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
}

struct PatternCellView: View {
    let index: Int
    let isHighlighted: Bool
    let wasSelected: Bool
    let isShowingPattern: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(borderColor, lineWidth: 3)
                }
                .scaleEffect(isHighlighted ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHighlighted)
        }
        .buttonStyle(.plain)
        .disabled(isShowingPattern)
    }

    private var backgroundColor: Color {
        if isHighlighted {
            return .blue
        } else if wasSelected {
            return .green.opacity(0.6)
        } else {
            return Color(.systemGray5)
        }
    }

    private var borderColor: Color {
        if isHighlighted {
            return .blue.opacity(0.8)
        } else if wasSelected {
            return .green
        } else {
            return Color(.systemGray4)
        }
    }
}

#Preview {
    PatternPuzzleView(difficulty: .easy) {
        print("Completed!")
    }
}
