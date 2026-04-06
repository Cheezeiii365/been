import Foundation
import SwiftData

struct FlightyImportService {

    struct ImportResult {
        let imported: Int
        let skipped: Int
        let errors: [String]
    }

    // ICAO airline code to display name
    private static let airlineNames: [String: String] = [
        "AAL": "American Airlines",
        "DAL": "Delta Air Lines",
        "UAL": "United Airlines",
        "SWA": "Southwest Airlines",
        "JBU": "JetBlue Airways",
        "ASA": "Alaska Airlines",
        "NKS": "Spirit Airlines",
        "FFT": "Frontier Airlines",
        "HAL": "Hawaiian Airlines",
        "EIN": "Aer Lingus",
        "DLH": "Lufthansa",
        "BAW": "British Airways",
        "AFR": "Air France",
        "KLM": "KLM Royal Dutch Airlines",
        "UAE": "Emirates",
        "QTR": "Qatar Airways",
        "SIA": "Singapore Airlines",
        "ANA": "All Nippon Airways",
        "JAL": "Japan Airlines",
        "CPA": "Cathay Pacific",
        "RYR": "Ryanair",
        "EZY": "easyJet",
        "WJA": "WestJet",
        "ACA": "Air Canada",
        "TAP": "TAP Air Portugal",
        "IBE": "Iberia",
        "SAS": "Scandinavian Airlines",
        "THY": "Turkish Airlines",
        "ETH": "Ethiopian Airlines",
        "QFA": "Qantas",
        "VIR": "Virgin Atlantic",
    ]

    static func parseCSV(from url: URL, modelContext: ModelContext) throws -> ImportResult {
        let content = try readSecurityScopedFile(url: url)

        let rows = parseCSVRows(content)
        guard rows.count > 1 else {
            throw ImportError.emptyFile
        }

        let headers = rows[0]
        let headerMap = Dictionary(uniqueKeysWithValues: headers.enumerated().map { ($1, $0) })

        // Fetch existing flightyIDs to avoid duplicates
        let existingFlights = (try? modelContext.fetch(FetchDescriptor<Flight>())) ?? []
        let existingIDs = Set(existingFlights.compactMap { $0.flightyID })

        var imported = 0
        var skipped = 0
        var errors: [String] = []

        for i in 1..<rows.count {
            let fields = rows[i]
            guard fields.count >= 10 else { continue }

            do {
                let flight = try parseFlight(fields: fields, headerMap: headerMap)

                if let fid = flight.flightyID, existingIDs.contains(fid) {
                    skipped += 1
                    continue
                }

                modelContext.insert(flight)
                imported += 1
            } catch {
                let lineDesc = col(fields, headerMap, "From") ?? "?"
                let toDesc = col(fields, headerMap, "To") ?? "?"
                errors.append("Row \(i + 1) (\(lineDesc)→\(toDesc)): \(error.localizedDescription)")
            }
        }

        try modelContext.save()
        return ImportResult(imported: imported, skipped: skipped, errors: errors)
    }

    private static func parseFlight(fields: [String], headerMap: [String: Int]) throws -> Flight {
        guard let fromCode = col(fields, headerMap, "From"), !fromCode.isEmpty,
              let toCode = col(fields, headerMap, "To"), !toCode.isEmpty else {
            throw ImportError.missingRoute
        }

        let depAirport = AirportDatabase.find(code: fromCode)
        let arrAirport = AirportDatabase.find(code: toCode)

        let depLat = depAirport?.latitude ?? 0
        let depLon = depAirport?.longitude ?? 0
        let arrLat = arrAirport?.latitude ?? 0
        let arrLon = arrAirport?.longitude ?? 0

        // Prefer actual times, fall back to scheduled
        let depTime = parseDate(col(fields, headerMap, "Gate Departure (Actual)"))
                   ?? parseDate(col(fields, headerMap, "Gate Departure (Scheduled)"))
        let arrTime = parseDate(col(fields, headerMap, "Gate Arrival (Actual)"))
                   ?? parseDate(col(fields, headerMap, "Gate Arrival (Scheduled)"))

        let airlineCode = col(fields, headerMap, "Airline") ?? ""
        let airlineName = airlineNames[airlineCode] ?? airlineCode

        let flightNum = col(fields, headerMap, "Flight")
        let fullFlightNumber: String? = if let num = flightNum, !num.isEmpty {
            "\(airlineCode) \(num)"
        } else {
            nil
        }

        let canceled = col(fields, headerMap, "Canceled")?.lowercased() == "true"

        let cabinClass = parseCabinClass(col(fields, headerMap, "Cabin Class"))

        let status: FlightStatus = if canceled {
            .cancelled
        } else if let dep = depTime, dep < Date() {
            .completed
        } else {
            .scheduled
        }

        let flight = Flight(
            departureAirportCode: fromCode,
            arrivalAirportCode: toCode,
            departureLat: depLat,
            departureLon: depLon,
            arrivalLat: arrLat,
            arrivalLon: arrLon,
            flightNumber: fullFlightNumber,
            airline: airlineName,
            departureTime: depTime,
            arrivalTime: arrTime,
            cabinClass: cabinClass,
            status: status
        )

        flight.departureAirportName = depAirport?.name
        flight.arrivalAirportName = arrAirport?.name
        flight.seatNumber = nonEmpty(col(fields, headerMap, "Seat"))
        flight.bookingReference = nonEmpty(col(fields, headerMap, "PNR"))
        flight.notes = nonEmpty(col(fields, headerMap, "Notes"))
        flight.aircraftType = nonEmpty(col(fields, headerMap, "Aircraft Type Name"))
        flight.tailNumber = nonEmpty(col(fields, headerMap, "Tail Number"))
        flight.flightyID = nonEmpty(col(fields, headerMap, "Flight Flighty ID"))

        if depLat != 0 && arrLat != 0 {
            flight.distanceMiles = LocationService.distance(
                from: (lat: depLat, lon: depLon),
                to: (lat: arrLat, lon: arrLon)
            )
        }

        return flight
    }

    // MARK: - File Reading

    private static func readSecurityScopedFile(url: URL) throws -> String {
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }

        var coordinatorError: NSError?
        var readContent: String?
        var readError: Error?

        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinatorError) { coordinatedURL in
            do {
                readContent = try String(contentsOf: coordinatedURL, encoding: .utf8)
            } catch {
                readError = error
            }
        }

        if let coordinatorError {
            throw ImportError.fileAccess(coordinatorError.localizedDescription)
        }
        if let readError {
            throw readError
        }
        guard let content = readContent, !content.isEmpty else {
            throw ImportError.invalidEncoding
        }
        return content
    }

    // MARK: - CSV Parsing

    /// Parses CSV handling quoted fields with commas.
    /// Uses enumerateLines for row splitting to avoid Swift's \r\n grapheme cluster issue.
    private static func parseCSVRows(_ content: String) -> [[String]] {
        var rows: [[String]] = []
        content.enumerateLines { line, _ in
            let fields = parseCSVLine(line)
            if !fields.allSatisfy({ $0.isEmpty }) {
                rows.append(fields)
            }
        }
        return rows
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        var i = line.startIndex

        while i < line.endIndex {
            let c = line[i]
            if inQuotes {
                if c == "\"" {
                    let next = line.index(after: i)
                    if next < line.endIndex && line[next] == "\"" {
                        currentField.append("\"")
                        i = line.index(after: next)
                        continue
                    } else {
                        inQuotes = false
                    }
                } else {
                    currentField.append(c)
                }
            } else {
                if c == "\"" {
                    inQuotes = true
                } else if c == "," {
                    fields.append(currentField)
                    currentField = ""
                } else {
                    currentField.append(c)
                }
            }
            i = line.index(after: i)
        }
        fields.append(currentField)
        return fields
    }

    // MARK: - Helpers

    private static func col(_ fields: [String], _ map: [String: Int], _ key: String) -> String? {
        guard let idx = map[key], idx < fields.count else { return nil }
        let val = fields[idx].trimmingCharacters(in: .whitespaces)
        return val.isEmpty ? nil : val
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let v = value, !v.isEmpty else { return nil }
        return v
    }

    private static func parseDate(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        // Flighty exports: "2012-12-01T18:15" or "2020-12-26T16:58:01"
        if let date = formatter.date(from: string) { return date }

        // Try without seconds
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm"
        df.locale = Locale(identifier: "en_US_POSIX")
        if let date = df.date(from: string) { return date }

        // Try with seconds
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df.date(from: string)
    }

    private static func parseCabinClass(_ value: String?) -> CabinClass {
        guard let value = value?.lowercased() else { return .economy }
        switch value {
        case "first": return .first
        case "business": return .business
        case "premium economy", "premium": return .premiumEconomy
        default: return .economy
        }
    }

    enum ImportError: LocalizedError {
        case invalidEncoding
        case emptyFile
        case missingRoute
        case fileAccess(String)

        var errorDescription: String? {
            switch self {
            case .invalidEncoding: return "Could not read file as text"
            case .emptyFile: return "CSV file is empty or could not be parsed"
            case .missingRoute: return "Missing departure or arrival airport"
            case .fileAccess(let detail): return "Could not access file: \(detail)"
            }
        }
    }
}
