import Foundation

struct Airport: Identifiable, Hashable, Codable {
    var id: String { code }
    let code: String // IATA code
    let name: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double

    var displayName: String {
        "\(name) (\(code))"
    }

    var shortDisplayName: String {
        "\(code) – \(city)"
    }
}

// Common airports for the built-in database
struct AirportDatabase {
    static let airports: [Airport] = [
        Airport(code: "JFK", name: "John F. Kennedy International", city: "New York", country: "US", latitude: 40.6413, longitude: -73.7781),
        Airport(code: "LAX", name: "Los Angeles International", city: "Los Angeles", country: "US", latitude: 33.9425, longitude: -118.4081),
        Airport(code: "ORD", name: "O'Hare International", city: "Chicago", country: "US", latitude: 41.9742, longitude: -87.9073),
        Airport(code: "LHR", name: "Heathrow", city: "London", country: "GB", latitude: 51.4700, longitude: -0.4543),
        Airport(code: "CDG", name: "Charles de Gaulle", city: "Paris", country: "FR", latitude: 49.0097, longitude: 2.5479),
        Airport(code: "NRT", name: "Narita International", city: "Tokyo", country: "JP", latitude: 35.7647, longitude: 140.3864),
        Airport(code: "HND", name: "Haneda", city: "Tokyo", country: "JP", latitude: 35.5494, longitude: 139.7798),
        Airport(code: "DXB", name: "Dubai International", city: "Dubai", country: "AE", latitude: 25.2532, longitude: 55.3657),
        Airport(code: "SIN", name: "Changi", city: "Singapore", country: "SG", latitude: 1.3644, longitude: 103.9915),
        Airport(code: "ICN", name: "Incheon International", city: "Seoul", country: "KR", latitude: 37.4602, longitude: 126.4407),
        Airport(code: "SFO", name: "San Francisco International", city: "San Francisco", country: "US", latitude: 37.6213, longitude: -122.3790),
        Airport(code: "MIA", name: "Miami International", city: "Miami", country: "US", latitude: 25.7959, longitude: -80.2870),
        Airport(code: "ATL", name: "Hartsfield-Jackson Atlanta International", city: "Atlanta", country: "US", latitude: 33.6407, longitude: -84.4277),
        Airport(code: "AMS", name: "Schiphol", city: "Amsterdam", country: "NL", latitude: 52.3105, longitude: 4.7683),
        Airport(code: "FRA", name: "Frankfurt", city: "Frankfurt", country: "DE", latitude: 50.0379, longitude: 8.5622),
        Airport(code: "FCO", name: "Leonardo da Vinci–Fiumicino", city: "Rome", country: "IT", latitude: 41.8003, longitude: 12.2389),
        Airport(code: "BCN", name: "Josep Tarradellas Barcelona–El Prat", city: "Barcelona", country: "ES", latitude: 41.2974, longitude: 2.0833),
        Airport(code: "SYD", name: "Sydney Kingsford Smith", city: "Sydney", country: "AU", latitude: -33.9461, longitude: 151.1772),
        Airport(code: "MEX", name: "Benito Juárez International", city: "Mexico City", country: "MX", latitude: 19.4363, longitude: -99.0721),
        Airport(code: "GRU", name: "São Paulo–Guarulhos International", city: "São Paulo", country: "BR", latitude: -23.4356, longitude: -46.4731),
        Airport(code: "BKK", name: "Suvarnabhumi", city: "Bangkok", country: "TH", latitude: 13.6900, longitude: 100.7501),
        Airport(code: "IST", name: "Istanbul", city: "Istanbul", country: "TR", latitude: 41.2753, longitude: 28.7519),
        Airport(code: "DEL", name: "Indira Gandhi International", city: "New Delhi", country: "IN", latitude: 28.5562, longitude: 77.1000),
        Airport(code: "HKG", name: "Hong Kong International", city: "Hong Kong", country: "HK", latitude: 22.3080, longitude: 113.9185),
        Airport(code: "DEN", name: "Denver International", city: "Denver", country: "US", latitude: 39.8561, longitude: -104.6737),
        Airport(code: "SEA", name: "Seattle-Tacoma International", city: "Seattle", country: "US", latitude: 47.4502, longitude: -122.3088),
        Airport(code: "BOS", name: "Logan International", city: "Boston", country: "US", latitude: 42.3656, longitude: -71.0096),
        Airport(code: "DFW", name: "Dallas/Fort Worth International", city: "Dallas", country: "US", latitude: 32.8998, longitude: -97.0403),
        Airport(code: "YYZ", name: "Toronto Pearson International", city: "Toronto", country: "CA", latitude: 43.6777, longitude: -79.6248),
        Airport(code: "LIS", name: "Humberto Delgado", city: "Lisbon", country: "PT", latitude: 38.7756, longitude: -9.1354),
        Airport(code: "CPH", name: "Copenhagen", city: "Copenhagen", country: "DK", latitude: 55.6180, longitude: 12.6561),
        Airport(code: "MUC", name: "Munich", city: "Munich", country: "DE", latitude: 48.3537, longitude: 11.7750),
        Airport(code: "ZRH", name: "Zurich", city: "Zurich", country: "CH", latitude: 47.4647, longitude: 8.5492),
        Airport(code: "DOH", name: "Hamad International", city: "Doha", country: "QA", latitude: 25.2731, longitude: 51.6081),
        Airport(code: "DUB", name: "Dublin", city: "Dublin", country: "IE", latitude: 53.4264, longitude: -6.2499),
        Airport(code: "JNB", name: "O.R. Tambo International", city: "Johannesburg", country: "ZA", latitude: -26.1392, longitude: 28.2460),
        Airport(code: "NBO", name: "Jomo Kenyatta International", city: "Nairobi", country: "KE", latitude: -1.3192, longitude: 36.9278),
        Airport(code: "CAI", name: "Cairo International", city: "Cairo", country: "EG", latitude: 30.1219, longitude: 31.4056),
        Airport(code: "LAS", name: "Harry Reid International", city: "Las Vegas", country: "US", latitude: 36.0840, longitude: -115.1537),
        Airport(code: "MSP", name: "Minneapolis-Saint Paul International", city: "Minneapolis", country: "US", latitude: 44.8848, longitude: -93.2223),
    ]

    static func search(_ query: String) -> [Airport] {
        let lowered = query.lowercased()
        return airports.filter {
            $0.code.lowercased().contains(lowered) ||
            $0.name.lowercased().contains(lowered) ||
            $0.city.lowercased().contains(lowered)
        }
    }

    static func find(code: String) -> Airport? {
        airports.first { $0.code == code.uppercased() }
    }
}
