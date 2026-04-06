import SwiftUI
import SwiftData

struct AddFlightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip?

    @State private var departureSearch = ""
    @State private var arrivalSearch = ""
    @State private var selectedDeparture: Airport?
    @State private var selectedArrival: Airport?
    @State private var flightNumber = ""
    @State private var airline = ""
    @State private var departureTime = Date()
    @State private var arrivalTime = Date()
    @State private var cabinClass: CabinClass = .economy
    @State private var status: FlightStatus = .scheduled
    @State private var seatNumber = ""
    @State private var bookingRef = ""
    @State private var notes = ""

    var departureResults: [Airport] {
        guard departureSearch.count >= 2 else { return [] }
        return AirportDatabase.search(departureSearch)
    }

    var arrivalResults: [Airport] {
        guard arrivalSearch.count >= 2 else { return [] }
        return AirportDatabase.search(arrivalSearch)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "airplane.departure")
                                .foregroundStyle(WandrTheme.accentTeal)
                            if let dep = selectedDeparture {
                                Text("\(dep.code) – \(dep.city)")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Button("Change") {
                                    selectedDeparture = nil
                                    departureSearch = ""
                                }
                                .font(.system(size: 12))
                                .foregroundStyle(WandrTheme.accentTeal)
                            } else {
                                TextField("From (airport code or city)", text: $departureSearch)
                                    .textInputAutocapitalization(.characters)
                            }
                        }

                        if selectedDeparture == nil && !departureResults.isEmpty {
                            ForEach(departureResults.prefix(5)) { airport in
                                Button {
                                    selectedDeparture = airport
                                    departureSearch = airport.code
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(airport.shortDisplayName)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.primary)
                                        Text(airport.name)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "airplane.arrival")
                                .foregroundStyle(WandrTheme.accentViolet)
                            if let arr = selectedArrival {
                                Text("\(arr.code) – \(arr.city)")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Button("Change") {
                                    selectedArrival = nil
                                    arrivalSearch = ""
                                }
                                .font(.system(size: 12))
                                .foregroundStyle(WandrTheme.accentTeal)
                            } else {
                                TextField("To (airport code or city)", text: $arrivalSearch)
                                    .textInputAutocapitalization(.characters)
                            }
                        }

                        if selectedArrival == nil && !arrivalResults.isEmpty {
                            ForEach(arrivalResults.prefix(5)) { airport in
                                Button {
                                    selectedArrival = airport
                                    arrivalSearch = airport.code
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(airport.shortDisplayName)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.primary)
                                        Text(airport.name)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }

                Section("Flight Info") {
                    TextField("Flight Number (e.g. UA 123)", text: $flightNumber)
                        .textInputAutocapitalization(.characters)
                    TextField("Airline", text: $airline)

                    Picker("Cabin", selection: $cabinClass) {
                        ForEach(CabinClass.allCases) { cabin in
                            Text(cabin.rawValue).tag(cabin)
                        }
                    }

                    Picker("Status", selection: $status) {
                        ForEach(FlightStatus.allCases) { s in
                            Label(s.rawValue, systemImage: s.icon).tag(s)
                        }
                    }
                }

                Section("Times") {
                    DatePicker("Departure", selection: $departureTime)
                    DatePicker("Arrival", selection: $arrivalTime, in: departureTime...)
                }

                Section("Optional") {
                    TextField("Seat Number", text: $seatNumber)
                    TextField("Booking Reference", text: $bookingRef)
                        .textInputAutocapitalization(.characters)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveFlight() }
                        .disabled(selectedDeparture == nil || selectedArrival == nil)
                        .foregroundStyle(selectedDeparture != nil && selectedArrival != nil ? WandrTheme.accentTeal : Color.gray)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func saveFlight() {
        guard let dep = selectedDeparture, let arr = selectedArrival else { return }

        let distance = LocationService.distance(
            from: (lat: dep.latitude, lon: dep.longitude),
            to: (lat: arr.latitude, lon: arr.longitude)
        )

        let flight = Flight(
            departureAirportCode: dep.code,
            arrivalAirportCode: arr.code,
            departureLat: dep.latitude,
            departureLon: dep.longitude,
            arrivalLat: arr.latitude,
            arrivalLon: arr.longitude,
            flightNumber: flightNumber.isEmpty ? nil : flightNumber,
            airline: airline.isEmpty ? nil : airline,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            cabinClass: cabinClass,
            status: status
        )
        flight.departureAirportName = dep.name
        flight.arrivalAirportName = arr.name
        flight.seatNumber = seatNumber.isEmpty ? nil : seatNumber
        flight.bookingReference = bookingRef.isEmpty ? nil : bookingRef
        flight.notes = notes.isEmpty ? nil : notes
        flight.distanceMiles = distance
        flight.trip = trip

        modelContext.insert(flight)
        try? modelContext.save()
        dismiss()
    }
}
