import Foundation

class QuizService {

    func fetchQuestions() async throws -> [Question] {

        let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

        let (data, _) = try await URLSession.shared.data(from: url)

        let quiz = try JSONDecoder().decode(QuizResponse.self, from: data)

        return quiz.results
    }
}
