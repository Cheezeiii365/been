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
        Airport(code: "AUS", name: "Austin-Bergstrom International", city: "Austin", country: "US", latitude: 30.1975, longitude: -97.6664),
        Airport(code: "BDL", name: "Bradley International", city: "Hartford", country: "US", latitude: 41.9389, longitude: -72.6832),
        Airport(code: "BHM", name: "Birmingham-Shuttlesworth International", city: "Birmingham", country: "US", latitude: 33.5629, longitude: -86.7535),
        Airport(code: "BNA", name: "Nashville International", city: "Nashville", country: "US", latitude: 36.1263, longitude: -86.6774),
        Airport(code: "BUF", name: "Buffalo Niagara International", city: "Buffalo", country: "US", latitude: 42.9405, longitude: -78.7322),
        Airport(code: "BWI", name: "Baltimore/Washington International", city: "Baltimore", country: "US", latitude: 39.1754, longitude: -76.6683),
        Airport(code: "CLT", name: "Charlotte Douglas International", city: "Charlotte", country: "US", latitude: 35.2140, longitude: -80.9431),
        Airport(code: "DAL", name: "Dallas Love Field", city: "Dallas", country: "US", latitude: 32.8471, longitude: -96.8518),
        Airport(code: "DCA", name: "Ronald Reagan Washington National", city: "Washington D.C.", country: "US", latitude: 38.8512, longitude: -77.0402),
        Airport(code: "DTW", name: "Detroit Metropolitan Wayne County", city: "Detroit", country: "US", latitude: 42.2124, longitude: -83.3534),
        Airport(code: "EWR", name: "Newark Liberty International", city: "Newark", country: "US", latitude: 40.6895, longitude: -74.1745),
        Airport(code: "FAT", name: "Fresno Yosemite International", city: "Fresno", country: "US", latitude: 36.7762, longitude: -119.7181),
        Airport(code: "FLL", name: "Fort Lauderdale-Hollywood International", city: "Fort Lauderdale", country: "US", latitude: 26.0726, longitude: -80.1527),
        Airport(code: "GLA", name: "Glasgow International", city: "Glasgow", country: "GB", latitude: 55.8642, longitude: -4.4316),
        Airport(code: "GRR", name: "Gerald R. Ford International", city: "Grand Rapids", country: "US", latitude: 42.8808, longitude: -85.5228),
        Airport(code: "HHH", name: "Hilton Head Island", city: "Hilton Head", country: "US", latitude: 32.2244, longitude: -80.6975),
        Airport(code: "HNL", name: "Daniel K. Inouye International", city: "Honolulu", country: "US", latitude: 21.3187, longitude: -157.9225),
        Airport(code: "HOU", name: "William P. Hobby", city: "Houston", country: "US", latitude: 29.6454, longitude: -95.2789),
        Airport(code: "IAH", name: "George Bush Intercontinental", city: "Houston", country: "US", latitude: 29.9844, longitude: -95.3414),
        Airport(code: "LGA", name: "LaGuardia", city: "New York", country: "US", latitude: 40.7769, longitude: -73.8740),
        Airport(code: "MCI", name: "Kansas City International", city: "Kansas City", country: "US", latitude: 39.2976, longitude: -94.7139),
        Airport(code: "MCO", name: "Orlando International", city: "Orlando", country: "US", latitude: 28.4312, longitude: -81.3081),
        Airport(code: "MDW", name: "Chicago Midway International", city: "Chicago", country: "US", latitude: 41.7868, longitude: -87.7522),
        Airport(code: "MSY", name: "Louis Armstrong New Orleans International", city: "New Orleans", country: "US", latitude: 29.9934, longitude: -90.2580),
        Airport(code: "NAP", name: "Naples International", city: "Naples", country: "IT", latitude: 40.8860, longitude: 14.2908),
        Airport(code: "ROC", name: "Greater Rochester International", city: "Rochester", country: "US", latitude: 43.1189, longitude: -77.6724),
        Airport(code: "SAV", name: "Savannah/Hilton Head International", city: "Savannah", country: "US", latitude: 32.1276, longitude: -81.2021),
        Airport(code: "SLC", name: "Salt Lake City International", city: "Salt Lake City", country: "US", latitude: 40.7884, longitude: -111.9778),
        Airport(code: "STL", name: "St. Louis Lambert International", city: "St. Louis", country: "US", latitude: 38.7487, longitude: -90.3700),
        Airport(code: "TPA", name: "Tampa International", city: "Tampa", country: "US", latitude: 27.9755, longitude: -82.5332),
        Airport(code: "TYS", name: "McGhee Tyson", city: "Knoxville", country: "US", latitude: 35.8110, longitude: -83.9940),
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
