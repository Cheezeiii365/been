import Foundation
import SwiftData

@Model
final class Trip {
    var title: String
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var purpose: TripPurpose
    var isActive: Bool

    @Relationship(deleteRule: .cascade, inverse: \TripStop.trip)
    var stops: [TripStop] = []

    @Relationship(deleteRule: .cascade, inverse: \Flight.trip)
    var flights: [Flight] = []

    var countries: [Country] = []

    var sortedStops: [TripStop] {
        stops.sorted { ($0.arrivalDate ?? .distantPast) < ($1.arrivalDate ?? .distantPast) }
    }

    var sortedFlights: [Flight] {
        flights.sorted { ($0.departureTime ?? .distantPast) < ($1.departureTime ?? .distantPast) }
    }

    var durationDays: Int {
        guard let end = endDate ?? stops.compactMap(\.departureDate).max() else {
            return Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        }
        return max(1, Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 1)
    }

    var countryCount: Int {
        Set(stops.compactMap { $0.city?.country?.code }).count
    }

    var cityCount: Int {
        Set(stops.compactMap { $0.city?.id }).count
    }

    var coverCity: City? {
        sortedStops.first?.city
    }

    init(title: String, startDate: Date, endDate: Date? = nil, notes: String? = nil, purpose: TripPurpose = .leisure, isActive: Bool = false) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.purpose = purpose
        self.isActive = isActive
    }
}

enum TripPurpose: String, Codable, CaseIterable, Identifiable {
    case leisure = "Leisure"
    case business = "Business"
    case tour = "Tour"
    case relocation = "Relocation"
    case layover = "Layover"
    case digitalNomad = "Digital Nomad"
    case familyVisit = "Family Visit"
    case conference = "Conference"
    case adventure = "Adventure"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .leisure: return "sun.max.fill"
        case .business: return "briefcase.fill"
        case .tour: return "music.mic"
        case .relocation: return "house.fill"
        case .layover: return "airplane"
        case .digitalNomad: return "laptopcomputer"
        case .familyVisit: return "heart.fill"
        case .conference: return "person.3.fill"
        case .adventure: return "figure.hiking"
        }
    }

    var color: String {
        switch self {
        case .leisure: return "tripLeisure"
        case .business: return "tripBusiness"
        case .tour: return "tripTour"
        case .relocation: return "tripRelocation"
        case .layover: return "tripLayover"
        case .digitalNomad: return "tripNomad"
        case .familyVisit: return "tripFamily"
        case .conference: return "tripConference"
        case .adventure: return "tripAdventure"
        }
    }
}
