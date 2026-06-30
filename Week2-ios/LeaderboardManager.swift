import Foundation
import Combine

struct LeaderboardEntry: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
    let date: Date
}

class LeaderboardManager: ObservableObject {
    static let shared = LeaderboardManager()
    
    @Published var tapFrenzyScores: [LeaderboardEntry] = []
    @Published var lightItUpScores: [LeaderboardEntry] = []
    @Published var quizRushScores: [LeaderboardEntry] = []
    
    private init() {
        loadAllScores()
    }
    
    
    func isHighScore(score: Int, game: String) -> Bool {
        return score > 0
    }
    
    func addEntry(name: String, score: Int, game: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let newEntry = LeaderboardEntry(name: trimmedName.isEmpty ? "Anonymous" : trimmedName, score: score, date: Date())
        var currentScores = getScores(for: game)
        
        currentScores.append(newEntry)
        currentScores.sort { $0.score > $1.score }
        
        saveScores(currentScores, game: game)
    }
    
    private func getScores(for game: String) -> [LeaderboardEntry] {
        switch game {
        case "tap": return tapFrenzyScores
        case "light": return lightItUpScores
        case "quiz": return quizRushScores
        default: return []
        }
    }
    
    private func saveScores(_ scores: [LeaderboardEntry], game: String) {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: "leaderboard_\(game)")
            loadAllScores()
        }
    }
    
    func loadAllScores() {
        tapFrenzyScores = loadScores(for: "tap")
        lightItUpScores = loadScores(for: "light")
        quizRushScores = loadScores(for: "quiz")
    }
    
    private func loadScores(for game: String) -> [LeaderboardEntry] {
        if let data = UserDefaults.standard.data(forKey: "leaderboard_\(game)"),
           let decoded = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            return decoded
        }
        return []
    }
}
