import Foundation
import SwiftData

@Model
final class Flight {
    var flightNumber: String?
    var airline: String?
    var departureAirportCode: String
    var arrivalAirportCode: String
    var departureAirportName: String?
    var arrivalAirportName: String?
    var departureTime: Date?
    var arrivalTime: Date?
    var departureLat: Double
    var departureLon: Double
    var arrivalLat: Double
    var arrivalLon: Double
    var seatNumber: String?
    var cabinClass: CabinClass
    var bookingReference: String?
    var status: FlightStatus
    var notes: String?
    var distanceMiles: Double?
    var aircraftType: String?
    var tailNumber: String?
    var flightyID: String?

    var trip: Trip?

    var durationMinutes: Int? {
        guard let dep = departureTime, let arr = arrivalTime else { return nil }
        return Calendar.current.dateComponents([.minute], from: dep, to: arr).minute
    }

    var durationDescription: String {
        guard let minutes = durationMinutes else { return "—" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours == 0 { return "\(mins)m" }
        return "\(hours)h \(mins)m"
    }

    var routeDescription: String {
        "\(departureAirportCode) → \(arrivalAirportCode)"
    }

    init(
        departureAirportCode: String,
        arrivalAirportCode: String,
        departureLat: Double,
        departureLon: Double,
        arrivalLat: Double,
        arrivalLon: Double,
        flightNumber: String? = nil,
        airline: String? = nil,
        departureTime: Date? = nil,
        arrivalTime: Date? = nil,
        cabinClass: CabinClass = .economy,
        status: FlightStatus = .scheduled
    ) {
        self.departureAirportCode = departureAirportCode
        self.arrivalAirportCode = arrivalAirportCode
        self.departureLat = departureLat
        self.departureLon = departureLon
        self.arrivalLat = arrivalLat
        self.arrivalLon = arrivalLon
        self.flightNumber = flightNumber
        self.airline = airline
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.cabinClass = cabinClass
        self.status = status
    }
}

enum CabinClass: String, Codable, CaseIterable, Identifiable {
    case economy = "Economy"
    case premiumEconomy = "Premium Economy"
    case business = "Business"
    case first = "First"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .economy: return "Y"
        case .premiumEconomy: return "W"
        case .business: return "J"
        case .first: return "F"
        }
    }
}

enum FlightStatus: String, Codable, CaseIterable, Identifiable {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case delayed = "Delayed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .scheduled: return "clock"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .delayed: return "exclamationmark.triangle.fill"
        }
    }
}
