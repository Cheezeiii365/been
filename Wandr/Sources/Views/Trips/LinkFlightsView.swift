import SwiftUI
import SwiftData

struct LinkFlightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    @Query(sort: \Flight.departureTime, order: .reverse) private var allFlights: [Flight]
    @State private var selectedFlightIDs: Set<PersistentIdentifier> = []

    private var unlinkedFlights: [Flight] {
        allFlights.filter { $0.trip == nil }
    }

    private var suggestedFlights: [Flight] {
        let buffer: TimeInterval = 86400
        let start = trip.startDate.addingTimeInterval(-buffer)
        let end = (trip.endDate ?? trip.startDate.addingTimeInterval(30 * 86400)).addingTimeInterval(buffer)

        return unlinkedFlights.filter { flight in
            guard let dep = flight.departureTime else { return false }
            return dep >= start && dep <= end
        }.sorted { ($0.departureTime ?? .distantPast) < ($1.departureTime ?? .distantPast) }
    }

    private var otherFlights: [Flight] {
        let suggestedIDs = Set(suggestedFlights.map(\.persistentModelID))
        return unlinkedFlights
            .filter { !suggestedIDs.contains($0.persistentModelID) }
            .sorted { ($0.departureTime ?? .distantPast) > ($1.departureTime ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if unlinkedFlights.isEmpty {
                    emptyState
                } else {
                    flightsList
                }
            }
            .background { WandrTheme.meshBackground() }
            .navigationTitle("Link Flights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Link \(selectedFlightIDs.count)") {
                        linkSelected()
                    }
                    .disabled(selectedFlightIDs.isEmpty)
                    .foregroundStyle(selectedFlightIDs.isEmpty ? Color.gray : WandrTheme.accentTeal)
                    .fontWeight(.bold)
                }
            }
        }
    }

    private var flightsList: some View {
        ScrollView {
            VStack(spacing: WandrTheme.spacingMD) {
                if !suggestedFlights.isEmpty {
                    Button {
                        let ids = Set(suggestedFlights.map(\.persistentModelID))
                        if ids.isSubset(of: selectedFlightIDs) {
                            selectedFlightIDs.subtract(ids)
                        } else {
                            selectedFlightIDs.formUnion(ids)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(WandrTheme.accentAmber)
                            Text("Select all \(suggestedFlights.count) flights in date range")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: allSuggestedSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(allSuggestedSelected ? WandrTheme.accentTeal : Color.gray)
                        }
                        .padding(WandrTheme.spacingMD)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
                    }
                }

                if !suggestedFlights.isEmpty {
                    sectionHeader("Suggested — within trip dates", count: suggestedFlights.count)
                    ForEach(suggestedFlights, id: \.persistentModelID) { flight in
                        flightRow(flight)
                    }
                }

                if !otherFlights.isEmpty {
                    sectionHeader("Other flights", count: otherFlights.count)
                    ForEach(otherFlights, id: \.persistentModelID) { flight in
                        flightRow(flight)
                    }
                }
            }
            .padding(.horizontal, WandrTheme.spacingMD)
            .padding(.bottom, 100)
        }
    }

    private var allSuggestedSelected: Bool {
        let ids = Set(suggestedFlights.map(\.persistentModelID))
        return !ids.isEmpty && ids.isSubset(of: selectedFlightIDs)
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .padding(.top, WandrTheme.spacingSM)
    }

    private func flightRow(_ flight: Flight) -> some View {
        let isSelected = selectedFlightIDs.contains(flight.persistentModelID)
        return Button {
            if isSelected {
                selectedFlightIDs.remove(flight.persistentModelID)
            } else {
                selectedFlightIDs.insert(flight.persistentModelID)
            }
        } label: {
            HStack(spacing: WandrTheme.spacingSM) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? WandrTheme.accentTeal : Color.gray)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(flight.routeDescription)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                        Spacer()
                        if let time = flight.departureTime {
                            Text(time.shortFormatted)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: WandrTheme.spacingSM) {
                        if let airline = flight.airline {
                            Text(airline)
                                .font(.system(size: 12))
                                .foregroundStyle(.tertiary)
                        }
                        if let num = flight.flightNumber {
                            Text(num)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Text(flight.durationDescription)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .glassCardDense()
            .overlay(
                RoundedRectangle(cornerRadius: WandrTheme.radiusSM)
                    .stroke(isSelected ? WandrTheme.accentTeal.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: WandrTheme.spacingMD) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No unlinked flights")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
            Text("All flights are already linked to trips")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func linkSelected() {
        for flight in allFlights where selectedFlightIDs.contains(flight.persistentModelID) {
            flight.trip = trip
        }
        try? modelContext.save()
        dismiss()
    }
}
