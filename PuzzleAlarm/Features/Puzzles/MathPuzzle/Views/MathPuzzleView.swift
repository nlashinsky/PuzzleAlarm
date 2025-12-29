import SwiftUI

struct MathPuzzleView: View {
    let difficulty: Difficulty
    let onComplete: () -> Void

    @State private var viewModel: MathPuzzleViewModel
    @State private var showError = false
    @FocusState private var isInputFocused: Bool

    init(difficulty: Difficulty, onComplete: @escaping () -> Void) {
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = State(initialValue: MathPuzzleViewModel(difficulty: difficulty))
    }

    var body: some View {
        VStack(spacing: 32) {
            // Progress
            Text("Problem \(viewModel.progress)")
                .font(.headline)
                .foregroundStyle(.secondary)

            // Problem display
            Text(viewModel.expression)
                .font(.system(size: 48, weight: .medium, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            // Answer input
            VStack(spacing: 16) {
                HStack {
                    Text("=")
                        .font(.system(size: 36, weight: .medium))

                    TextField("?", text: $viewModel.userInput)
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 150)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .focused($isInputFocused)
                }

                if showError {
                    Text("Incorrect - try again!")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }

            // Submit button
            Button(action: submitAnswer) {
                Text("Submit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.userInput.isEmpty ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.userInput.isEmpty)

            // Number pad for easier input
            NumberPadView(value: $viewModel.userInput)
        }
        .padding()
        .onAppear {
            isInputFocused = true
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                onComplete()
            }
        }
    }

    private func submitAnswer() {
        withAnimation {
            if viewModel.checkAnswer() {
                showError = false
            } else {
                showError = true
                viewModel.userInput = ""

                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
}

struct NumberPadView: View {
    @Binding var value: String

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...9, id: \.self) { number in
                NumberButton(number: "\(number)") {
                    value += "\(number)"
                }
            }

            NumberButton(number: "C", color: .orange) {
                value = ""
            }

            NumberButton(number: "0") {
                value += "0"
            }

            NumberButton(number: "⌫", color: .gray) {
                if !value.isEmpty {
                    value.removeLast()
                }
            }
        }
    }
}

struct NumberButton: View {
    let number: String
    var color: Color = .blue

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    MathPuzzleView(difficulty: .medium) {
        print("Completed!")
    }
}
