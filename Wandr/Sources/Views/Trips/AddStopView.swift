import SwiftUI
import SwiftData

struct AddStopView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Country.name) private var countries: [Country]

    let trip: Trip

    @State private var cityName = ""
    @State private var selectedCountry: Country?
    @State private var arrivalDate: Date
    @State private var departureDate: Date
    @State private var hasDeparture = true
    @State private var notes = ""
    @State private var rating: Int = 0
    @State private var accommodation = ""
    @State private var highlightText = ""
    @State private var highlights: [String] = []
    @State private var searchCountryText = ""

    init(trip: Trip) {
        self.trip = trip
        let defaultDate = trip.endDate ?? Date()
        _arrivalDate = State(initialValue: defaultDate)
        _departureDate = State(initialValue: defaultDate)
    }

    var filteredCountries: [Country] {
        if searchCountryText.isEmpty { return countries }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchCountryText) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    TextField("City Name", text: $cityName)
                        .font(.system(size: 16, weight: .medium))

                    // Country picker with search
                    Picker("Country", selection: $selectedCountry) {
                        Text("Select Country").tag(nil as Country?)
                        ForEach(countries, id: \.self) { country in
                            Text("\(country.flagEmoji) \(country.name)").tag(country as Country?)
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
                                .foregroundStyle(star <= rating ? WandrTheme.accentOrange : WandrTheme.textTertiary)
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
                                .foregroundStyle(WandrTheme.accentCyan)
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
                                                .foregroundStyle(WandrTheme.textTertiary)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(WandrTheme.accentCyan.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(WandrTheme.background)
            .navigationTitle("Add City Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveStop()
                    }
                    .disabled(cityName.isEmpty || selectedCountry == nil)
                    .foregroundStyle(cityName.isEmpty ? WandrTheme.textTertiary : WandrTheme.accentCyan)
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func saveStop() {
        guard let country = selectedCountry else { return }

        // Find or create city
        let cityId = "\(country.code):\(cityName)"
        let descriptor = FetchDescriptor<City>(predicate: #Predicate { $0.id == cityId })
        let existingCity = try? modelContext.fetch(descriptor).first

        let city: City
        if let existing = existingCity {
            city = existing
        } else {
            city = City(
                name: cityName,
                countryCode: country.code,
                latitude: country.latitude + Double.random(in: -2...2),
                longitude: country.longitude + Double.random(in: -2...2)
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

        // Add country to trip if not already there
        if !trip.countries.contains(where: { $0.code == country.code }) {
            trip.countries.append(country)
        }

        try? modelContext.save()
        dismiss()
    }
}
