import CoreLocation
import Foundation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

protocol LocationServiceProtocol: Sendable {
    func getCurrentLocation() async throws -> Coordinate
    func distanceBetween(from: Coordinate, to: Coordinate) -> Double
}

final class CoreLocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate, @unchecked Sendable {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<Coordinate, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func getCurrentLocation() async throws -> Coordinate {
        locationManager.requestWhenInUseAuthorization()

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }

    func distanceBetween(from: Coordinate, to: Coordinate) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0 // Return in km
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        continuation?.resume(returning: Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ))
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
