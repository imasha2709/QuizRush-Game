import Foundation
import CoreLocation
import Combine

class GameSessionManager: ObservableObject {
    static let shared = GameSessionManager()

    @Published var sessions: [GameSession] = []
    private let saveKey = "GAME_SESSIONS"

    private init() {
        load()
    }

    func saveGame(
        game: GameMode,
        score: Int,
        location: CLLocationCoordinate2D? = LocationService.shared.currentLocation
    ) {
   
        var finalLatitude = location?.latitude
        var finalLongitude = location?.longitude
        
       
        if let lat = finalLatitude, let lon = finalLongitude {
            let jitterRange = 0.0003
            finalLatitude = lat + Double.random(in: -jitterRange...jitterRange)
            finalLongitude = lon + Double.random(in: -jitterRange...jitterRange)
        }

     
        let session = GameSession(
            game: game,
            score: score,
            latitude: finalLatitude,
            longitude: finalLongitude
        )

        DispatchQueue.main.async {
            // Inserts the new game session at the top of the history list
            self.sessions.insert(session, at: 0)
            self.save()
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("❌ Storage Error: \(error.localizedDescription)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }

        do {
            sessions = try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("❌ Decoding Error: \(error.localizedDescription)")
        }
    }

    func clearHistory() {
        sessions.removeAll()
        save()
    }
}
