import Foundation
import SwiftData

@Model
final class Country {
    @Attribute(.unique) var code: String // ISO 3166-1 alpha-2
    var name: String
    var continent: Continent
    var flagEmoji: String
    var latitude: Double
    var longitude: Double

    @Relationship(deleteRule: .cascade, inverse: \City.country)
    var cities: [City] = []

    @Relationship(inverse: \Trip.countries)
    var trips: [Trip] = []

    var isVisited: Bool {
        !cities.isEmpty || !trips.isEmpty
    }

    var totalVisits: Int {
        trips.count
    }

    var totalDaysSpent: Int {
        trips.reduce(0) { total, trip in
            let stops = trip.stops.filter { $0.city?.country?.code == self.code }
            return total + stops.reduce(0) { $0 + ($1.durationDays ?? 0) }
        }
    }

    init(code: String, name: String, continent: Continent, flagEmoji: String, latitude: Double, longitude: Double) {
        self.code = code
        self.name = name
        self.continent = continent
        self.flagEmoji = flagEmoji
        self.latitude = latitude
        self.longitude = longitude
    }
}

enum Continent: String, Codable, CaseIterable, Identifiable {
    case africa = "Africa"
    case antarctica = "Antarctica"
    case asia = "Asia"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case oceania = "Oceania"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .africa: return "🌍"
        case .antarctica: return "🧊"
        case .asia: return "🌏"
        case .europe: return "🌍"
        case .northAmerica: return "🌎"
        case .southAmerica: return "🌎"
        case .oceania: return "🌏"
        }
    }
}
