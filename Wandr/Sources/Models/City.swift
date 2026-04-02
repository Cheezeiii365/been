import Foundation
import SwiftData

@Model
final class City {
    @Attribute(.unique) var id: String // compound key: "country_code:city_name"
    var name: String
    var state: String?
    var latitude: Double
    var longitude: Double
    var timeZoneIdentifier: String?
    var population: Int?

    var country: Country?

    @Relationship(deleteRule: .cascade, inverse: \TripStop.city)
    var tripStops: [TripStop] = []

    var isVisited: Bool {
        !tripStops.isEmpty
    }

    var totalVisits: Int {
        tripStops.count
    }

    var totalDaysSpent: Int {
        tripStops.reduce(0) { $0 + ($1.durationDays ?? 0) }
    }

    var firstVisited: Date? {
        tripStops.compactMap(\.arrivalDate).min()
    }

    var lastVisited: Date? {
        tripStops.compactMap(\.arrivalDate).max()
    }

    init(name: String, countryCode: String, latitude: Double, longitude: Double, state: String? = nil, timeZoneIdentifier: String? = nil, population: Int? = nil) {
        self.id = "\(countryCode):\(name)"
        self.name = name
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
        self.population = population
    }
}
