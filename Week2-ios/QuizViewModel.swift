import SwiftUI
import Combine

@MainActor
class QuizViewModel: ObservableObject {

    @Published var questions: [Question] = []
    @Published var currentQuestion = 0
    @Published var score = 0
    @Published var streak = 0
    
    @Published var isLoading = true
    @Published var hasError = false
    @Published var finished = false
    
 
    @Published var timeRemaining: Double = 10.0
    private var timerTask: Task<Void, Never>?

    private let service = QuizService()

    func loadQuestions() {
        isLoading = true
        hasError = false
        finished = false
        score = 0
        streak = 0
        currentQuestion = 0
        
        Task {
            do {
                let fetchedQuestions = try await service.fetchQuestions()
                self.questions = fetchedQuestions
                self.isLoading = false
                if !fetchedQuestions.isEmpty {
                    startTimer()
                }
            } catch {
                self.hasError = true
                self.isLoading = false
            }
        }
    }

    func startTimer() {
        timerTask?.cancel()
        timeRemaining = 10.0
        
        timerTask = Task {
            while timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard !Task.isCancelled else { return }
                timeRemaining -= 0.1
            }
         
            streak = 0
            advanceToNextQuestion()
        }
    }

    func processAnswerSelection(_ answer: String) -> Bool {
        timerTask?.cancel()
        guard currentQuestion < questions.count else { return false }
        
        let isCorrect = (answer == questions[currentQuestion].correct_answer)
        
        if isCorrect {
            streak += 1
          
            let speedBonus = Int(timeRemaining * 2)
            score += (10 + speedBonus) * streak
        } else {
            streak = 0
        }
        
        return isCorrect
    }

    func advanceToNextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            startTimer()
        } else {
            finished = true
        }
    }

    func restart() {
        loadQuestions()
    }
}
