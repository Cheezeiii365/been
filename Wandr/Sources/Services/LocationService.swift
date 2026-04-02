import Foundation
import CoreLocation
import SwiftData

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func reverseGeocode(location: CLLocation) async -> (city: String?, country: String?, countryCode: String?, state: String?)? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else { return nil }
            return (
                city: placemark.locality,
                country: placemark.country,
                countryCode: placemark.isoCountryCode,
                state: placemark.administrativeArea
            )
        } catch {
            return nil
        }
    }

    func geocode(address: String) async -> CLLocation? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            return placemarks.first?.location
        } catch {
            return nil
        }
    }

    static func distance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
        let loc1 = CLLocation(latitude: from.lat, longitude: from.lon)
        let loc2 = CLLocation(latitude: to.lat, longitude: to.lon)
        return loc1.distance(from: loc2) / 1609.34 // Convert meters to miles
    }
}
