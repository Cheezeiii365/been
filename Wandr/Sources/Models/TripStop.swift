import Foundation
import SwiftData

@Model
final class TripStop {
    var arrivalDate: Date?
    var departureDate: Date?
    var notes: String?
    var rating: Int? // 1-5 stars
    var highlights: [String] = []
    var accommodation: String?
    var sortOrder: Int

    var city: City?
    var trip: Trip?

    var durationDays: Int? {
        guard let arrival = arrivalDate, let departure = departureDate else { return nil }
        return max(1, Calendar.current.dateComponents([.day], from: arrival, to: departure).day ?? 1)
    }

    var durationDescription: String {
        guard let days = durationDays else { return "Unknown" }
        if days == 1 { return "1 day" }
        if days < 7 { return "\(days) days" }
        let weeks = days / 7
        let remainingDays = days % 7
        if remainingDays == 0 { return "\(weeks)w" }
        return "\(weeks)w \(remainingDays)d"
    }

    init(arrivalDate: Date? = nil, departureDate: Date? = nil, notes: String? = nil, rating: Int? = nil, sortOrder: Int = 0) {
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.notes = notes
        self.rating = rating
        self.sortOrder = sortOrder
    }
}
