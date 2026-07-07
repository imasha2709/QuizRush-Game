import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {

    @Published var questions: [Question] = []

    @Published var currentQuestion = 0

    @Published var score = 0

    @Published var isLoading = true

    @Published var hasError = false

    @Published var finished = false

    private let service = QuizService()

    func loadQuestions() {

        Task {

            isLoading = true
            hasError = false

            do {

                questions = try await service.fetchQuestions()

                isLoading = false

            } catch {

                hasError = true

                isLoading = false

            }

        }

    }

    func checkAnswer(_ answer: String) {

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