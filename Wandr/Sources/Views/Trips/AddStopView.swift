import SwiftUI
import SwiftData
import MapKit

struct AddStopView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip

    @State private var citySearch = CitySearchService()
    @State private var resolvedCity: ResolvedCity?
    @State private var arrivalDate: Date
    @State private var departureDate: Date
    @State private var hasDeparture = true
    @State private var notes = ""
    @State private var rating: Int = 0
    @State private var accommodation = ""
    @State private var highlightText = ""
    @State private var highlights: [String] = []

    init(trip: Trip) {
        self.trip = trip
        let defaultDate = trip.endDate ?? Date()
        _arrivalDate = State(initialValue: defaultDate)
        _departureDate = State(initialValue: defaultDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    if let resolved = resolvedCity {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(resolved.name)
                                    .font(.system(size: 16, weight: .semibold))
                                Text([resolved.state, resolved.countryName].compactMap { $0 }.joined(separator: ", "))
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Change") {
                                resolvedCity = nil
                                citySearch.searchText = ""
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(WandrTheme.accentTeal)
                        }
                    } else {
                        TextField("Search city...", text: $citySearch.searchText)
                            .font(.system(size: 16, weight: .medium))
                            .autocorrectionDisabled()

                        if citySearch.isSearching {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Finding city...")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        ForEach(citySearch.suggestions.prefix(5), id: \.self) { suggestion in
                            Button {
                                selectSuggestion(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.primary)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Arrival", selection: $arrivalDate, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Has Departure", isOn: $hasDeparture)
                    if hasDeparture {
                        DatePicker("Departure", selection: $departureDate, in: arrivalDate..., displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section("Rating") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 24))
                                .foregroundStyle(star <= rating ? WandrTheme.accentAmber : Color.gray)
                                .onTapGesture {
                                    rating = star == rating ? 0 : star
                                }
                        }
                    }
                }

                Section("Details") {
                    TextField("Accommodation", text: $accommodation)

                    HStack {
                        TextField("Add highlight", text: $highlightText)
                        Button {
                            if !highlightText.isEmpty {
                                highlights.append(highlightText)
                                highlightText = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(WandrTheme.accentTeal)
                        }
                    }

                    if !highlights.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(highlights, id: \.self) { highlight in
                                    HStack(spacing: 4) {
                                        Text(highlight)
                                            .font(.system(size: 12))
                                        Button {
                                            highlights.removeAll { $0 == highlight }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(WandrTheme.accentTeal.opacity(0.12), in: Capsule())
                                }
                            }
                        }
                    }

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add City Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { saveStop() }
                        .disabled(resolvedCity == nil)
                        .foregroundStyle(resolvedCity == nil ? Color.gray : WandrTheme.accentTeal)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        Task {
            if let resolved = await citySearch.resolveCity(suggestion) {
                resolvedCity = resolved
            }
        }
    }

    private func saveStop() {
        guard let resolved = resolvedCity else { return }

        let country = findOrCreateCountry(code: resolved.countryCode, name: resolved.countryName)

        let cityId = "\(resolved.countryCode):\(resolved.name)"
        let descriptor = FetchDescriptor<City>(predicate: #Predicate { $0.id == cityId })
        let existingCity = try? modelContext.fetch(descriptor).first

        let city: City
        if let existing = existingCity {
            city = existing
            // Update coordinates if they were previously random
            city.latitude = resolved.latitude
            city.longitude = resolved.longitude
            if let tz = resolved.timeZoneIdentifier { city.timeZoneIdentifier = tz }
            if let state = resolved.state { city.state = state }
        } else {
            city = City(
                name: resolved.name,
                countryCode: resolved.countryCode,
                latitude: resolved.latitude,
                longitude: resolved.longitude,
                state: resolved.state,
                timeZoneIdentifier: resolved.timeZoneIdentifier
            )
            city.country = country
            modelContext.insert(city)
        }

        let stop = TripStop(
            arrivalDate: arrivalDate,
            departureDate: hasDeparture ? departureDate : nil,
            notes: notes.isEmpty ? nil : notes,
            rating: rating > 0 ? rating : nil,
            sortOrder: trip.stops.count
        )
        stop.highlights = highlights
        stop.accommodation = accommodation.isEmpty ? nil : accommodation
        stop.city = city
        stop.trip = trip

        modelContext.insert(stop)

        if !trip.countries.contains(where: { $0.code == country.code }) {
            trip.countries.append(country)
        }

        try? modelContext.save()
        dismiss()
    }

    private func findOrCreateCountry(code: String, name: String) -> Country {
        let descriptor = FetchDescriptor<Country>(predicate: #Predicate { $0.code == code })
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        // Country not in seeded list — create it
        let country = Country(
            code: code,
            name: name,
            continent: .europe, // Default; not critical for functionality
            flagEmoji: flagEmoji(for: code),
            latitude: 0,
            longitude: 0
        )
        modelContext.insert(country)
        return country
    }

    private func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        return countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value).map { String($0) }
        }.joined()
    }
}
