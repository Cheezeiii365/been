import Foundation
import SwiftData

struct TravelStats {
    let totalCountries: Int
    let totalCities: Int
    let totalTrips: Int
    let totalFlights: Int
    let totalDaysAbroad: Int
    let totalMilesFlown: Double
    let longestTrip: Trip?
    let shortestTrip: Trip?
    let mostVisitedCountry: (Country, Int)?
    let mostVisitedCity: (City, Int)?
    let continentCoverage: [Continent: Int]
    let tripsByPurpose: [TripPurpose: Int]
    let tripsByYear: [Int: Int]
    let countriesByContinent: [Continent: [Country]]

    var percentOfWorld: Double {
        Double(totalCountries) / 195.0 * 100.0
    }

    var averageTripLength: Double {
        guard totalTrips > 0 else { return 0 }
        return Double(totalDaysAbroad) / Double(totalTrips)
    }

    static let empty = TravelStats(
        totalCountries: 0,
        totalCities: 0,
        totalTrips: 0,
        totalFlights: 0,
        totalDaysAbroad: 0,
        totalMilesFlown: 0,
        longestTrip: nil,
        shortestTrip: nil,
        mostVisitedCountry: nil,
        mostVisitedCity: nil,
        continentCoverage: [:],
        tripsByPurpose: [:],
        tripsByYear: [:],
        countriesByContinent: [:]
    )
}
