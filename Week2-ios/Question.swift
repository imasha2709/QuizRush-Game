import Foundation

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    let id = UUID()
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
   
    let answers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correct_answer
        case incorrect_answers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decode(String.self, forKey: .question)
        self.correct_answer = try container.decode(String.self, forKey: .correct_answer)
        self.incorrect_answers = try container.decode([String].self, forKey: .incorrect_answers)
      
        self.answers = (incorrect_answers + [correct_answer]).shuffled()
    }
}
