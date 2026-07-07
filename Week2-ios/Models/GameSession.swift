import Foundation

struct GameSession: Identifiable, Codable {
    var id = UUID()
    let game: GameMode
    let score: Int
    let date: Date
    let latitude: Double?
    let longitude: Double?

    init(
        id: UUID = UUID(),
        game: GameMode,
        score: Int,
        date: Date = Date(),
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.game = game
        self.score = score
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
    }
}
