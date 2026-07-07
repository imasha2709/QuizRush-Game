import SwiftUI
import MapKit

struct GameMapView: View {
    @ObservedObject private var manager = GameSessionManager.shared
    @State private var cameraPosition = MapCameraPosition.automatic

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(manager.sessions) { session in
                    if let lat = session.latitude,
                       let lon = session.longitude {

                        Annotation(
                            session.game.rawValue,
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        ) {
                            // Creative Map Annotation Pin design
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(.red.gradient)
                                        .frame(width: 36, height: 36)
                                        .shadow(radius: 3)
                                    
                                    Image(systemName: "trophy.fill")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                }
                                
                                Text("\(session.score) pts")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.background)
                                    .clipShape(Capsule())
                                    .shadow(color: .black.opacity(0.15), radius: 2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Game Locations")
        }
    }
}
