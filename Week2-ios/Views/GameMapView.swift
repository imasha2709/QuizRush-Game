import SwiftUI
import MapKit
import CoreLocation
import Combine

struct GameMapView: View {
    @ObservedObject private var manager = GameSessionManager.shared
    @StateObject private var locationService = LocationService.shared
    
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
            span: MKCoordinateSpan(latitudeDelta: 4.0, longitudeDelta: 4.0)
        )
    )
    
    
    @State private var selectedSession: GameSession?
    
    private var localizedSessions: [GameSession] {
        manager.sessions.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var body: some View {
        NavigationStack {
        
            Map(position: $cameraPosition, selection: $selectedSession) {
                ForEach(localizedSessions) { session in
                    let coordinate = CLLocationCoordinate2D(
                        latitude: session.latitude ?? 0.0,
                        longitude: session.longitude ?? 0.0
                    )
                    
                   
                    Annotation(
                        "",
                        coordinate: coordinate
                    ) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 34, height: 34)
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                Circle()
                                    .fill(resolveColor(for: session.game).gradient)
                                    .frame(width: 28, height: 28)
                                Image(systemName: session.game.icon)
                                    .font(.system(size: 12))
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
                    .tag(session)
                }
            }
            .navigationTitle("Game Locations")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationService.requestLocationPermission()
            }
           
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
                    .presentationDetents([.fraction(0.3)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    

    private func resolveColor(for mode: GameMode) -> Color {
        switch mode.color {
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        default: return .primary
        }
    }
}


struct SessionDetailView: View {
    let session: GameSession
    @Environment(\.dismiss) private var dismiss

   
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
    
    private var gameColor: Color {
        switch session.game.color {
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        default: return .primary
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(gameColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: session.game.icon)
                        .font(.title2)
                        .foregroundColor(gameColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.game.rawValue)
                        .font(.headline)
                    Text("Played on \(formattedDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(session.score)")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(gameColor)
                    Text("POINTS")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 10)

            Divider()

            Button(action: openInAppleMaps) {
                HStack {
                    Image(systemName: "safari.fill")
                    Text("Get Directions in Apple Maps")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(gameColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
    }

   
    private func openInAppleMaps() {
        guard let lat = session.latitude, let lon = session.longitude else { return }
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(session.game.rawValue) - \(session.score) Points Match"
        
       
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
