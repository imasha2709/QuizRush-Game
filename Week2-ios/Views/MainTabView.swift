import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
            
            GameMapView()
                .tabItem {
                    Label("Locations", systemImage: "map.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
           
            LocationService.shared.requestLocationPermission()
        }
    }
}
