import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("homeAirport") private var homeAirport = ""
    @AppStorage("countLayovers") private var countLayovers = false
    @AppStorage("distanceUnit") private var distanceUnit = "miles"
    @AppStorage("showDisputedBorders") private var showDisputedBorders = false

    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @Query private var countries: [Country]
    @Query private var cities: [City]
    @Query private var flights: [Flight]

    @State private var showExportAlert = false
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    HStack(spacing: WandrTheme.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(WandrTheme.heroGradient)
                                .frame(width: 56, height: 56)
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Traveler")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(WandrTheme.textPrimary)
                            Text("\(countries.filter { $0.isVisited }.count) countries, \(cities.filter { $0.isVisited }.count) cities")
                                .font(.system(size: 13))
                                .foregroundStyle(WandrTheme.textSecondary)
                        }
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)
                }

                // Preferences
                Section("Preferences") {
                    HStack {
                        Label("Home Airport", systemImage: "house.fill")
                        Spacer()
                        TextField("e.g. JFK", text: $homeAirport)
                            .textInputAutocapitalization(.characters)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)

                    Toggle(isOn: $countLayovers) {
                        Label("Count Layovers as Visited", systemImage: "airplane.circle")
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)

                    Picker(selection: $distanceUnit) {
                        Text("Miles").tag("miles")
                        Text("Kilometers").tag("km")
                    } label: {
                        Label("Distance Unit", systemImage: "ruler")
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)
                }

                // Map Settings
                Section("Map") {
                    Toggle(isOn: $showDisputedBorders) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Show Disputed Borders", systemImage: "map")
                            Text("Display disputed territory borders on the map")
                                .font(.system(size: 12))
                                .foregroundStyle(WandrTheme.textTertiary)
                        }
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)
                }

                // Data
                Section("Data") {
                    HStack {
                        Label("Trips", systemImage: "suitcase.fill")
                        Spacer()
                        Text("\(trips.count)")
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)

                    HStack {
                        Label("Flights", systemImage: "airplane")
                        Spacer()
                        Text("\(flights.count)")
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)

                    HStack {
                        Label("Countries Visited", systemImage: "flag.fill")
                        Spacer()
                        Text("\(countries.filter { $0.isVisited }.count)")
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)

                    HStack {
                        Label("Cities Visited", systemImage: "building.2.fill")
                        Spacer()
                        Text("\(cities.filter { $0.isVisited }.count)")
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)
                }

                // About
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(WandrTheme.textTertiary)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)

                    Label("Rate Wandr", systemImage: "star.fill")
                        .foregroundStyle(WandrTheme.accentOrange)
                        .listRowBackground(WandrTheme.surfaceSecondary)
                }

                // Danger zone
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundStyle(WandrTheme.accentRed)
                    }
                    .listRowBackground(WandrTheme.surfaceSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(WandrTheme.background)
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your trips, flights, and travel data. This cannot be undone.")
            }
        }
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: TripStop.self)
            try modelContext.delete(model: Flight.self)
            try modelContext.delete(model: Trip.self)
            try modelContext.delete(model: City.self)
            try modelContext.save()
        } catch {
            print("Error resetting data: \(error)")
        }
    }
}
