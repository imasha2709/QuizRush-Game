import SwiftUI
import UserNotifications
import CoreLocation
import Combine

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        AppPermissionManager.shared.requestNotificationPermission()
        AppPermissionManager.shared.requestLocationPermission()
        
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

@main
struct Week2_iosApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var sessionManager = GameSessionManager.shared
    
   
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(sessionManager)
                
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

final class AppPermissionManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = AppPermissionManager()
    
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    
    override private init() {
        super.init()
        locationManager.delegate = self
        self.locationStatus = locationManager.authorizationStatus
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Root Service: Notification permission granted.")
                  
                    UIApplication.shared.registerForRemoteNotifications()
                    self.triggerSystemSettingsRegistration()
                } else if let error = error {
                    print("❌ Root Service: Notification permission failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func triggerSystemSettingsRegistration() {
        let content = UNMutableNotificationContent()
        content.title = "System Registered"
        content.body = "Notification channels initialized."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "sys_init_ping", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestLocationPermission() {
        DispatchQueue.main.async {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationStatus = manager.authorizationStatus
            print("🗺️ Root Service: Location status updated.")
        }
    }
}
