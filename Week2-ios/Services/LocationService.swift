import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func requestLocationPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Location permission denied by user.")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location Tracking Failure: \(error.localizedDescription)")
    }
}
