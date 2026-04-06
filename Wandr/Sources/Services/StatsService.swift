import Foundation
import SwiftData

@Observable
final class StatsService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func computeStats(year: Int? = nil) -> TravelStats {
        let trips = fetchTrips(year: year)
        let flights = fetchFlights(year: year)
        let visitedCountries = fetchVisitedCountries()
        let visitedCities = fetchVisitedCities()

        let totalDays = trips.reduce(0) { $0 + $1.durationDays }
        let totalMiles = flights.compactMap(\.distanceMiles).reduce(0, +)

        let longestTrip = trips.max(by: { $0.durationDays < $1.durationDays })
        let shortestTrip = trips.filter { $0.endDate != nil }.min(by: { $0.durationDays < $1.durationDays })

        // Most visited country
        var countryVisits: [String: (Country, Int)] = [:]
        for trip in trips {
            for stop in trip.stops {
                if let country = stop.city?.country {
                    let key = country.code
                    countryVisits[key, default: (country, 0)].1 += 1
                }
            }
        }
        let mostVisitedCountry = countryVisits.values.max(by: { $0.1 < $1.1 })

        // Most visited city
        var cityVisits: [String: (City, Int)] = [:]
        for trip in trips {
            for stop in trip.stops {
                if let city = stop.city {
                    let key = city.id
                    cityVisits[key, default: (city, 0)].1 += 1
                }
            }
        }
        let mostVisitedCity = cityVisits.values.max(by: { $0.1 < $1.1 })

        // Continent coverage
        var continentCoverage: [Continent: Int] = [:]
        for country in visitedCountries {
            continentCoverage[country.continent, default: 0] += 1
        }

        // Trips by purpose
        var tripsByPurpose: [TripPurpose: Int] = [:]
        for trip in trips {
            tripsByPurpose[trip.purpose, default: 0] += 1
        }

        // Trips by year
        var tripsByYear: [Int: Int] = [:]
        for trip in trips {
            let year = Calendar.current.component(.year, from: trip.startDate)
            tripsByYear[year, default: 0] += 1
        }

        // Countries by continent
        var countriesByContinent: [Continent: [Country]] = [:]
        for country in visitedCountries {
            countriesByContinent[country.continent, default: []].append(country)
        }

        return TravelStats(
            totalCountries: visitedCountries.count,
            totalCities: visitedCities.count,
            totalTrips: trips.count,
            totalFlights: flights.count,
            totalDaysAbroad: totalDays,
            totalMilesFlown: totalMiles,
            longestTrip: longestTrip,
            shortestTrip: shortestTrip,
            mostVisitedCountry: mostVisitedCountry,
            mostVisitedCity: mostVisitedCity,
            continentCoverage: continentCoverage,
            tripsByPurpose: tripsByPurpose,
            tripsByYear: tripsByYear,
            countriesByContinent: countriesByContinent
        )
    }

    private func fetchTrips(year: Int? = nil) -> [Trip] {
        let descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        var results = (try? modelContext.fetch(descriptor)) ?? []
        if let year = year {
            let calendar = Calendar.current
            let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
            results = results.filter { $0.startDate >= start && $0.startDate < end }
        }
        return results
    }

    private func fetchFlights(year: Int? = nil) -> [Flight] {
        let descriptor = FetchDescriptor<Flight>(sortBy: [SortDescriptor(\.departureTime, order: .reverse)])
        var results = (try? modelContext.fetch(descriptor)) ?? []
        if let year = year {
            let calendar = Calendar.current
            let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
            results = results.filter {
                guard let dt = $0.departureTime else { return false }
                return dt >= start && dt < end
            }
        }
        return results
    }

    private func fetchVisitedCountries() -> [Country] {
        let descriptor = FetchDescriptor<Country>(sortBy: [SortDescriptor(\.name)])
        let countries = (try? modelContext.fetch(descriptor)) ?? []
        return countries.filter { $0.isVisited }
    }

    private func fetchVisitedCities() -> [City] {
        let descriptor = FetchDescriptor<City>(sortBy: [SortDescriptor(\.name)])
        let cities = (try? modelContext.fetch(descriptor)) ?? []
        return cities.filter { $0.isVisited }
    }
}
