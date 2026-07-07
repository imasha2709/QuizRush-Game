import SwiftUI

struct QuizRushView: View {

    @StateObject private var vm = QuizViewModel()
    
    @State private var showNamePrompt = false
    @State private var playerNameInput = ""
    @AppStorage("playerName") var savedPlayerName = ""

    @State private var selectedAnswer: String? = nil
    @State private var isShowingFeedback = false

    private var progressFraction: Double {
        guard !vm.questions.isEmpty else { return 0.0 }
        return Double(vm.currentQuestion) / Double(vm.questions.count)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading {
                    Spacer()
                    ProgressView("Loading Rush Questions...")
                        .tint(.purple)
                    Spacer()
                }
                else if vm.hasError {
                    Spacer()
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Something went wrong")
                        .padding(.vertical, 8)
                    Button("Try Again") { vm.loadQuestions() }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                }
                else if vm.finished {
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)
                    
                    Text("Game Finished")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Final Score: \(vm.score)")
                        .font(.title2)
                        .foregroundColor(.purple)
                        .padding(.bottom, 20)
                    
                    Button("Play Again") { vm.restart() }
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .cornerRadius(12)
                    Spacer()
                }
                else if !vm.questions.isEmpty {
                    VStack(spacing: 20) {
                        
                        // 👤 ADDED: Dynamic profile welcome ribbon
                        if !savedPlayerName.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.purple)
                                Text(savedPlayerName)
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(20)
                        }
                
                        VStack(spacing: 8) {
                            HStack {
                                Text("Question \(vm.currentQuestion + 1)/\(vm.questions.count)")
                                    .font(.headline)
                                Spacer()
                                if vm.streak > 1 {
                                    Text("🔥 \(vm.streak)X STREAK")
                                        .font(.caption)
                                        .fontWeight(.black)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            
                            ProgressView(value: progressFraction, total: 1.0)
                                .tint(.purple)
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                .cornerRadius(4)
                            
                            HStack {
                                Image(systemName: "stopwatch.fill")
                                    .foregroundColor(vm.timeRemaining < 3 ? .red : .blue)
                                ProgressView(value: max(vm.timeRemaining, 0), total: 10.0)
                                    .tint(vm.timeRemaining < 3 ? .red : .blue)
                                Text(String(format: "%.1fs", max(vm.timeRemaining, 0)))
                                    .font(.caption).monospacedDigit()
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 4)

                        Text(vm.questions[vm.currentQuestion].question)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)

                        VStack(spacing: 12) {
                            ForEach(vm.questions[vm.currentQuestion].answers, id: \.self) { answer in
                                Button {
                                    handleAnswerTap(answer)
                                } label: {
                                    Text(answer)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(getButtonColor(for: answer))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                }
                                .disabled(isShowingFeedback)
                            }
                        }

                        Spacer()

                        // Live Dynamic Score Display Footer
                        Text("Score: \(vm.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                }
            }
            .navigationTitle("Quiz Rush")
            .task { vm.loadQuestions() }
            .onChange(of: vm.finished) { _, isFinished in
                if isFinished {
                    // ==========================================
                    // 🌟 REPAIR: Cleaned up broken 'currentCoordinates' call
                    // ==========================================
                    GameSessionManager.shared.saveGame(
                        game: .quizRush,
                        score: vm.score
                    )
                    
                    if LeaderboardManager.shared.isHighScore(score: vm.score, game: "quiz") {
                        playerNameInput = savedPlayerName.isEmpty ? "Player" : savedPlayerName
                        showNamePrompt = true
                    }
                }
            }
            .alert("New High Score!", isPresented: $showNamePrompt) {
                TextField("Enter your name", text: $playerNameInput)
                Button("Save") {
                    let structuredName = playerNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    let finalName = structuredName.isEmpty ? "Anonymous" : structuredName
                    savedPlayerName = finalName // Sync profile user defaults
                    LeaderboardManager.shared.addEntry(name: finalName, score: vm.score, game: "quiz")
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You generated a booming \(vm.score) score! Store your status on the board:")
            }
        }
    }

    private func handleAnswerTap(_ answer: String) {
        selectedAnswer = answer
        isShowingFeedback = true
        
        let isCorrect = vm.processAnswerSelection(answer)
        
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(isCorrect ? .success : .error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut) {
                vm.advanceToNextQuestion()
                self.selectedAnswer = nil
                self.isShowingFeedback = false
            }
        }
    }

    private func getButtonColor(for answer: String) -> Color {
        getButtonColorExplicitly(for: answer)
    }
    
    private func getButtonColorExplicitly(for answer: String) -> Color {
        guard isShowingFeedback else { return Color.blue }
        
        let correctTarget = vm.questions[vm.currentQuestion].correct_answer
        if answer == correctTarget {
            return Color.green
        } else if answer == selectedAnswer {
            return Color.red
        }
        return Color.blue.opacity(0.3)
    }
}
