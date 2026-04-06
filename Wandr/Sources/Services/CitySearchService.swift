import Foundation
@preconcurrency import MapKit

struct ResolvedCity: Sendable {
    let name: String
    let state: String?
    let countryName: String
    let countryCode: String
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String?
}

@MainActor
@Observable
final class CitySearchService: NSObject, @preconcurrency MKLocalSearchCompleterDelegate {
    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            if searchText.isEmpty {
                suggestions = []
            } else {
                completer.queryFragment = searchText
            }
        }
    }
    var suggestions: [MKLocalSearchCompletion] = []
    var isSearching = false

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    // MARK: - MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }

    // MARK: - Resolve

    func resolveCity(_ completion: MKLocalSearchCompletion) async -> ResolvedCity? {
        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            guard let item = response.mapItems.first else { return nil }
            let placemark = item.placemark

            let name = placemark.locality ?? placemark.name ?? completion.title
            let countryCode = placemark.isoCountryCode ?? ""
            let countryName = placemark.country ?? ""

            return ResolvedCity(
                name: name,
                state: placemark.administrativeArea,
                countryName: countryName,
                countryCode: countryCode,
                latitude: placemark.coordinate.latitude,
                longitude: placemark.coordinate.longitude,
                timeZoneIdentifier: item.timeZone?.identifier
            )
        } catch {
            return nil
        }
    }
}
