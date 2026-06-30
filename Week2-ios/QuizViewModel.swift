import SwiftUI
import Foundation
import Combine

@MainActor
class QuizViewModel: ObservableObject {

    @Published var questions: [Question] = []
    @Published var currentQuestion = 0
    @Published var score = 0
    @Published var isLoading = true
    @Published var hasError = false
    @Published var finished = false

    private let service = QuizService()

    func loadQuestions() {
        isLoading = true
        hasError = false
        
        Task {
            do {
                let fetchedQuestions = try await service.fetchQuestions()
                // Safely update state on the MainActor
                self.questions = fetchedQuestions
                self.isLoading = false
            } catch {
                self.hasError = true
                self.isLoading = false
            }
        }
    }

    func checkAnswer(_ answer: String) {
        guard currentQuestion < questions.count else { return }
        
        if answer == questions[currentQuestion].correct_answer {
            score += 1
        }

        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
        } else {
            finished = true
        }
    }

    func restart() {
        score = 0
        currentQuestion = 0
        finished = false
        loadQuestions()
    }
}
