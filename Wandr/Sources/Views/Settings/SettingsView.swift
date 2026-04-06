import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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

    @State private var showResetAlert = false
    @State private var showFlightyImporter = false
    @State private var importResult: FlightyImportService.ImportResult?
    @State private var showImportResult = false
    @State private var importError: String?
    @State private var showImportError = false
    @State private var isImporting = false

    var body: some View {
        NavigationStack {
            Form {
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
                                .foregroundStyle(.primary)
                            Text("\(countries.filter { $0.isVisited }.count) countries, \(cities.filter { $0.isVisited }.count) cities")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
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

                    Toggle(isOn: $countLayovers) {
                        Label("Count Layovers as Visited", systemImage: "airplane.circle")
                    }

                    Picker(selection: $distanceUnit) {
                        Text("Miles").tag("miles")
                        Text("Kilometers").tag("km")
                    } label: {
                        Label("Distance Unit", systemImage: "ruler")
                    }
                }

                // Map Settings
                Section("Map") {
                    Toggle(isOn: $showDisputedBorders) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Show Disputed Borders", systemImage: "map")
                            Text("Display disputed territory borders on the map")
                                .font(.system(size: 12))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                // Import
                Section("Import") {
                    Button {
                        showFlightyImporter = true
                    } label: {
                        HStack {
                            Label("Import from Flighty", systemImage: "airplane.circle.fill")
                                .foregroundStyle(WandrTheme.accentTeal)
                            Spacer()
                            if isImporting {
                                ProgressView()
                                    .tint(WandrTheme.accentTeal)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .disabled(isImporting)

                    Text("Export your flights from Flighty as CSV, then import here.")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                // Data
                Section("Data") {
                    HStack {
                        Label("Trips", systemImage: "suitcase.fill")
                        Spacer()
                        Text("\(trips.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Flights", systemImage: "airplane")
                        Spacer()
                        Text("\(flights.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Countries Visited", systemImage: "flag.fill")
                        Spacer()
                        Text("\(countries.filter { $0.isVisited }.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Cities Visited", systemImage: "building.2.fill")
                        Spacer()
                        Text("\(cities.filter { $0.isVisited }.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("2.0.0")
                            .foregroundStyle(.tertiary)
                    }

                    Label("Rate Wandr", systemImage: "star.fill")
                        .foregroundStyle(WandrTheme.accentAmber)
                }

                // Danger zone
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundStyle(WandrTheme.accentRed)
                    }
                }
            }
            .navigationTitle("Settings")
            .fileImporter(
                isPresented: $showFlightyImporter,
                allowedContentTypes: [UTType.commaSeparatedText, UTType.plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importFlightyCSV(url: url)
                case .failure(let error):
                    importError = error.localizedDescription
                    showImportError = true
                }
            }
            .alert("Import Complete", isPresented: $showImportResult) {
                Button("OK") {}
            } message: {
                if let r = importResult {
                    Text("\(r.imported) flights imported, \(r.skipped) duplicates skipped.\(r.errors.isEmpty ? "" : "\n\(r.errors.count) rows had errors.")")
                }
            }
            .alert("Import Failed", isPresented: $showImportError) {
                Button("OK") {}
            } message: {
                Text(importError ?? "Unknown error")
            }
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

    private func importFlightyCSV(url: URL) {
        isImporting = true
        do {
            let result = try FlightyImportService.parseCSV(from: url, modelContext: modelContext)
            isImporting = false
            importResult = result
            showImportResult = true
        } catch {
            isImporting = false
            importError = error.localizedDescription
            showImportError = true
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
