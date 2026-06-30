import SwiftUI

struct QuizRushView: View {

    @StateObject var vm = QuizViewModel()
    
    // Properties for Leaderboard integration
    @State private var showNamePrompt = false
    @State private var playerName = ""

    // Dynamic progress calculation (Returns a value between 0.0 and 1.0)
    private var progressFraction: Double {
        guard !vm.questions.isEmpty else { return 0.0 }
        return Double(vm.currentQuestion) / Double(vm.questions.count)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading {
                    Spacer()
                    ProgressView("Loading Questions...")
                    Spacer()
                }
                else if vm.hasError {
                    Spacer()
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Something went wrong")
                    
                    Button("Try Again") {
                        vm.loadQuestions()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                }
                else if vm.finished {
                    Spacer()
                    Image(systemName: "star.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)
                    
                    Text("Game Finished")
                        .font(.largeTitle)
                    
                    Text("Score: \(vm.score) / \(vm.questions.count)")
                        .font(.title2)
                    
                    Button("Play Again") {
                        vm.restart()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                else if !vm.questions.isEmpty {
                    VStack(spacing: 20) {
                        
                        // MARK: - Animated Progress Bar
                        VStack(spacing: 8) {
                            HStack {
                                Text("Question \(vm.currentQuestion + 1) / \(vm.questions.count)")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(progressFraction * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                            
                            ProgressView(value: progressFraction, total: 1.0)
                                .tint(.purple)
                                .scaleEffect(x: 1, y: 2, anchor: .center) // Increases bar thickness
                                .cornerRadius(4)
                                .animation(.easeInOut, value: vm.currentQuestion) // Animates changes
                        }
                        .padding(.horizontal, 4)

                        Text(vm.questions[vm.currentQuestion].question)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()

                        ForEach(vm.questions[vm.currentQuestion].answers, id: \.self) { answer in
                            Button {
                                withAnimation(.spring()) {
                                    vm.checkAnswer(answer)
                                }
                            } label: {
                                Text(answer)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            }
                        }

                        Spacer()

                        Text("Score : \(vm.score)")
                            .font(.title2)
                    }
                    .padding()
                } else {
                    Spacer()
                    Text("No questions available.")
                    Spacer()
                }
            }
            .navigationTitle("Quiz Rush")
            .task {
                vm.loadQuestions()
            }
            // Monitors when the state shifts to finished to evaluate Leaderboard status
            .onChange(of: vm.finished) { _, isFinished in
                if isFinished {
                    if LeaderboardManager.shared.isHighScore(score: vm.score, game: "quiz") {
                        showNamePrompt = true
                    }
                }
            }
            // Alert overlay interface to save player names
            .alert("New High Score!", isPresented: $showNamePrompt) {
                TextField("Enter your name", text: $playerName)
                
                Button("Save") {
                    LeaderboardManager.shared.addEntry(name: playerName, score: vm.score, game: "quiz")
                    playerName = "" // Clear state cache
                }
                
                Button("Cancel", role: .cancel) {
                    playerName = ""
                }
            } message: {
                Text("You scored \(vm.score) points! Write your name into glory history:")
            }
        }
    }
}

#Preview {
    QuizRushView()
}
