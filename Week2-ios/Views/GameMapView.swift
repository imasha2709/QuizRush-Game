import SwiftUI
import MapKit

struct GameMapView: View {
    @ObservedObject private var manager = GameSessionManager.shared
    
   
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
            span: MKCoordinateSpan(latitudeDelta: 4.0, longitudeDelta: 4.0)
        )
    )

    
    private var localizedSessions: [GameSession] {
        manager.sessions.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(localizedSessions) { session in
                   
                    Annotation(
                        "",
                        coordinate: CLLocationCoordinate2D(
                            latitude: session.latitude ?? 0.0,
                            longitude: session.longitude ?? 0.0
                        )
                    ) {
                        VStack(spacing: 6) {
                           
                            Text(session.game.rawValue)
                                .font(.system(size: 10, weight: .black, design: .default))
                                .textCase(.uppercase)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 6).fill(gameColor(for: session.game)))
                                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                            
                           
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                Circle()
                                    .fill(gameColor(for: session.game).gradient)
                                    .frame(width: 26, height: 26)
                                Image(systemName: "trophy.fill")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            
                         
                            Text("\(session.score) PTS")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(.systemBackground)))
                                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                        }
                    }
                }
            }
            .navigationTitle("Game Locations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func gameColor(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .green
        case .lightItUp: return .orange
        case .quizRush:  return .blue
        }
    }
}
