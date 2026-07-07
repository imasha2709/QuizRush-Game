import Foundation

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {

    let id = UUID()

    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    var answers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }

    enum CodingKeys: String, CodingKey {
        case question
        case correct_answer
        case incorrect_answers
    }
}