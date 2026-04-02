import Foundation
import SwiftData

struct CountryData {
    let code: String
    let name: String
    let continent: Continent
    let flag: String
    let lat: Double
    let lon: Double
}

struct CountryDataService {
    static let allCountries: [CountryData] = [
        CountryData(code: "US", name: "United States", continent: .northAmerica, flag: "🇺🇸", lat: 37.0902, lon: -95.7129),
        CountryData(code: "GB", name: "United Kingdom", continent: .europe, flag: "🇬🇧", lat: 55.3781, lon: -3.4360),
        CountryData(code: "FR", name: "France", continent: .europe, flag: "🇫🇷", lat: 46.2276, lon: 2.2137),
        CountryData(code: "DE", name: "Germany", continent: .europe, flag: "🇩🇪", lat: 51.1657, lon: 10.4515),
        CountryData(code: "IT", name: "Italy", continent: .europe, flag: "🇮🇹", lat: 41.8719, lon: 12.5674),
        CountryData(code: "ES", name: "Spain", continent: .europe, flag: "🇪🇸", lat: 40.4637, lon: -3.7492),
        CountryData(code: "JP", name: "Japan", continent: .asia, flag: "🇯🇵", lat: 36.2048, lon: 138.2529),
        CountryData(code: "KR", name: "South Korea", continent: .asia, flag: "🇰🇷", lat: 35.9078, lon: 127.7669),
        CountryData(code: "CN", name: "China", continent: .asia, flag: "🇨🇳", lat: 35.8617, lon: 104.1954),
        CountryData(code: "IN", name: "India", continent: .asia, flag: "🇮🇳", lat: 20.5937, lon: 78.9629),
        CountryData(code: "AU", name: "Australia", continent: .oceania, flag: "🇦🇺", lat: -25.2744, lon: 133.7751),
        CountryData(code: "NZ", name: "New Zealand", continent: .oceania, flag: "🇳🇿", lat: -40.9006, lon: 174.8860),
        CountryData(code: "BR", name: "Brazil", continent: .southAmerica, flag: "🇧🇷", lat: -14.2350, lon: -51.9253),
        CountryData(code: "AR", name: "Argentina", continent: .southAmerica, flag: "🇦🇷", lat: -38.4161, lon: -63.6167),
        CountryData(code: "MX", name: "Mexico", continent: .northAmerica, flag: "🇲🇽", lat: 23.6345, lon: -102.5528),
        CountryData(code: "CA", name: "Canada", continent: .northAmerica, flag: "🇨🇦", lat: 56.1304, lon: -106.3468),
        CountryData(code: "TH", name: "Thailand", continent: .asia, flag: "🇹🇭", lat: 15.8700, lon: 100.9925),
        CountryData(code: "VN", name: "Vietnam", continent: .asia, flag: "🇻🇳", lat: 14.0583, lon: 108.2772),
        CountryData(code: "ID", name: "Indonesia", continent: .asia, flag: "🇮🇩", lat: -0.7893, lon: 113.9213),
        CountryData(code: "SG", name: "Singapore", continent: .asia, flag: "🇸🇬", lat: 1.3521, lon: 103.8198),
        CountryData(code: "AE", name: "United Arab Emirates", continent: .asia, flag: "🇦🇪", lat: 23.4241, lon: 53.8478),
        CountryData(code: "TR", name: "Turkey", continent: .europe, flag: "🇹🇷", lat: 38.9637, lon: 35.2433),
        CountryData(code: "GR", name: "Greece", continent: .europe, flag: "🇬🇷", lat: 39.0742, lon: 21.8243),
        CountryData(code: "PT", name: "Portugal", continent: .europe, flag: "🇵🇹", lat: 39.3999, lon: -8.2245),
        CountryData(code: "NL", name: "Netherlands", continent: .europe, flag: "🇳🇱", lat: 52.1326, lon: 5.2913),
        CountryData(code: "CH", name: "Switzerland", continent: .europe, flag: "🇨🇭", lat: 46.8182, lon: 8.2275),
        CountryData(code: "SE", name: "Sweden", continent: .europe, flag: "🇸🇪", lat: 60.1282, lon: 18.6435),
        CountryData(code: "NO", name: "Norway", continent: .europe, flag: "🇳🇴", lat: 60.4720, lon: 8.4689),
        CountryData(code: "DK", name: "Denmark", continent: .europe, flag: "🇩🇰", lat: 56.2639, lon: 9.5018),
        CountryData(code: "FI", name: "Finland", continent: .europe, flag: "🇫🇮", lat: 61.9241, lon: 25.7482),
        CountryData(code: "IE", name: "Ireland", continent: .europe, flag: "🇮🇪", lat: 53.1424, lon: -7.6921),
        CountryData(code: "AT", name: "Austria", continent: .europe, flag: "🇦🇹", lat: 47.5162, lon: 14.5501),
        CountryData(code: "BE", name: "Belgium", continent: .europe, flag: "🇧🇪", lat: 50.5039, lon: 4.4699),
        CountryData(code: "PL", name: "Poland", continent: .europe, flag: "🇵🇱", lat: 51.9194, lon: 19.1451),
        CountryData(code: "CZ", name: "Czech Republic", continent: .europe, flag: "🇨🇿", lat: 49.8175, lon: 15.4730),
        CountryData(code: "HU", name: "Hungary", continent: .europe, flag: "🇭🇺", lat: 47.1625, lon: 19.5033),
        CountryData(code: "HR", name: "Croatia", continent: .europe, flag: "🇭🇷", lat: 45.1000, lon: 15.2000),
        CountryData(code: "RO", name: "Romania", continent: .europe, flag: "🇷🇴", lat: 45.9432, lon: 24.9668),
        CountryData(code: "ZA", name: "South Africa", continent: .africa, flag: "🇿🇦", lat: -30.5595, lon: 22.9375),
        CountryData(code: "EG", name: "Egypt", continent: .africa, flag: "🇪🇬", lat: 26.8206, lon: 30.8025),
        CountryData(code: "MA", name: "Morocco", continent: .africa, flag: "🇲🇦", lat: 31.7917, lon: -7.0926),
        CountryData(code: "KE", name: "Kenya", continent: .africa, flag: "🇰🇪", lat: -0.0236, lon: 37.9062),
        CountryData(code: "NG", name: "Nigeria", continent: .africa, flag: "🇳🇬", lat: 9.0820, lon: 8.6753),
        CountryData(code: "TZ", name: "Tanzania", continent: .africa, flag: "🇹🇿", lat: -6.3690, lon: 34.8888),
        CountryData(code: "CO", name: "Colombia", continent: .southAmerica, flag: "🇨🇴", lat: 4.5709, lon: -74.2973),
        CountryData(code: "PE", name: "Peru", continent: .southAmerica, flag: "🇵🇪", lat: -9.1900, lon: -75.0152),
        CountryData(code: "CL", name: "Chile", continent: .southAmerica, flag: "🇨🇱", lat: -35.6751, lon: -71.5430),
        CountryData(code: "PH", name: "Philippines", continent: .asia, flag: "🇵🇭", lat: 12.8797, lon: 121.7740),
        CountryData(code: "MY", name: "Malaysia", continent: .asia, flag: "🇲🇾", lat: 4.2105, lon: 101.9758),
        CountryData(code: "QA", name: "Qatar", continent: .asia, flag: "🇶🇦", lat: 25.3548, lon: 51.1839),
        CountryData(code: "IS", name: "Iceland", continent: .europe, flag: "🇮🇸", lat: 64.9631, lon: -19.0208),
        CountryData(code: "IL", name: "Israel", continent: .asia, flag: "🇮🇱", lat: 31.0461, lon: 34.8516),
        CountryData(code: "JO", name: "Jordan", continent: .asia, flag: "🇯🇴", lat: 30.5852, lon: 36.2384),
        CountryData(code: "RU", name: "Russia", continent: .europe, flag: "🇷🇺", lat: 61.5240, lon: 105.3188),
        CountryData(code: "UA", name: "Ukraine", continent: .europe, flag: "🇺🇦", lat: 48.3794, lon: 31.1656),
        CountryData(code: "SA", name: "Saudi Arabia", continent: .asia, flag: "🇸🇦", lat: 23.8859, lon: 45.0792),
        CountryData(code: "CR", name: "Costa Rica", continent: .northAmerica, flag: "🇨🇷", lat: 9.7489, lon: -83.7534),
        CountryData(code: "PA", name: "Panama", continent: .northAmerica, flag: "🇵🇦", lat: 8.5380, lon: -80.7821),
        CountryData(code: "CU", name: "Cuba", continent: .northAmerica, flag: "🇨🇺", lat: 21.5218, lon: -77.7812),
        CountryData(code: "JM", name: "Jamaica", continent: .northAmerica, flag: "🇯🇲", lat: 18.1096, lon: -77.2975),
        CountryData(code: "GH", name: "Ghana", continent: .africa, flag: "🇬🇭", lat: 7.9465, lon: -1.0232),
        CountryData(code: "ET", name: "Ethiopia", continent: .africa, flag: "🇪🇹", lat: 9.1450, lon: 40.4897),
        CountryData(code: "TW", name: "Taiwan", continent: .asia, flag: "🇹🇼", lat: 23.6978, lon: 120.9605),
        CountryData(code: "HK", name: "Hong Kong", continent: .asia, flag: "🇭🇰", lat: 22.3193, lon: 114.1694),
        CountryData(code: "FJ", name: "Fiji", continent: .oceania, flag: "🇫🇯", lat: -17.7134, lon: 178.0650),
        CountryData(code: "MV", name: "Maldives", continent: .asia, flag: "🇲🇻", lat: 3.2028, lon: 73.2207),
        CountryData(code: "MT", name: "Malta", continent: .europe, flag: "🇲🇹", lat: 35.9375, lon: 14.3754),
        CountryData(code: "LU", name: "Luxembourg", continent: .europe, flag: "🇱🇺", lat: 49.8153, lon: 6.1296),
        CountryData(code: "MC", name: "Monaco", continent: .europe, flag: "🇲🇨", lat: 43.7384, lon: 7.4246),
    ]

    static func seed(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Country>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        for data in allCountries {
            let country = Country(
                code: data.code,
                name: data.name,
                continent: data.continent,
                flagEmoji: data.flag,
                latitude: data.lat,
                longitude: data.lon
            )
            modelContext.insert(country)
        }
        try? modelContext.save()
    }
}
