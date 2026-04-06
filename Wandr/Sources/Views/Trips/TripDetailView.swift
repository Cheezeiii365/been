import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: Trip
    @State private var showAddStop = false
    @State private var showAddFlight = false
    @State private var showLinkFlights = false
    @State private var showEditTrip = false

    var body: some View {
        ScrollView {
            VStack(spacing: WandrTheme.spacingMD) {
                tripHeader
                tripQuickStats
                if !trip.sortedStops.isEmpty {
                    timelineSection
                }
                flightsSection
                if let notes = trip.notes, !notes.isEmpty {
                    notesSection(notes)
                }
                actionsSection
            }
            .padding(.horizontal, WandrTheme.spacingMD)
            .padding(.bottom, 100)
        }
        .background { WandrTheme.meshBackground() }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditTrip = true
                    } label: {
                        Label("Edit Trip", systemImage: "pencil")
                    }

                    Button {
                        trip.isActive.toggle()
                    } label: {
                        Label(trip.isActive ? "End Trip" : "Mark Active", systemImage: trip.isActive ? "stop.circle" : "play.circle")
                    }

                    Divider()

                    Button(role: .destructive) {
                        modelContext.delete(trip)
                    } label: {
                        Label("Delete Trip", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $showAddStop) {
            AddStopView(trip: trip)
        }
        .sheet(isPresented: $showAddFlight) {
            AddFlightView(trip: trip)
        }
        .sheet(isPresented: $showLinkFlights) {
            LinkFlightsView(trip: trip)
        }
        .sheet(isPresented: $showEditTrip) {
            EditTripView(trip: trip)
        }
    }

    // MARK: - Trip Header
    private var tripHeader: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Label(trip.purpose.rawValue, systemImage: trip.purpose.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WandrTheme.purposeColor(trip.purpose))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(WandrTheme.purposeColor(trip.purpose).opacity(0.15), in: Capsule())

                if trip.isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(WandrTheme.accentEmerald)
                            .frame(width: 6, height: 6)
                        Text("ACTIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(WandrTheme.accentEmerald)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(WandrTheme.accentEmerald.opacity(0.15), in: Capsule())
                }
            }

            Text(trip.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            HStack(spacing: WandrTheme.spacingSM) {
                Image(systemName: "calendar")
                    .foregroundStyle(WandrTheme.accentTeal)
                Text(trip.startDate.shortFormatted)
                if let end = trip.endDate {
                    Text("–")
                    Text(end.shortFormatted)
                } else {
                    Text("– present")
                }
            }
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, WandrTheme.spacingSM)
    }

    // MARK: - Quick Stats
    private var tripQuickStats: some View {
        HStack {
            MiniStatBadge(label: "Days", value: "\(trip.durationDays)", color: WandrTheme.accentTeal)
            Divider().frame(height: 30)
            MiniStatBadge(label: "Countries", value: "\(trip.countryCount)", color: WandrTheme.accentViolet)
            Divider().frame(height: 30)
            MiniStatBadge(label: "Cities", value: "\(trip.cityCount)", color: WandrTheme.accentAmber)
            Divider().frame(height: 30)
            MiniStatBadge(label: "Flights", value: "\(trip.flights.count)", color: WandrTheme.accentIndigo)
        }
        .glassCard()
    }

    // MARK: - Timeline
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Text("Timeline")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Button { showAddStop = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(WandrTheme.accentTeal)
                }
            }

            ForEach(Array(trip.sortedStops.enumerated()), id: \.element) { index, stop in
                TimelineStopRow(stop: stop, isLast: index == trip.sortedStops.count - 1)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteStop(stop)
                        } label: {
                            Label("Delete Stop", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private func deleteStop(_ stop: TripStop) {
        modelContext.delete(stop)
        try? modelContext.save()
    }

    // MARK: - Flights
    private var flightsSection: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Text("Flights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Menu {
                    Button {
                        showLinkFlights = true
                    } label: {
                        Label("Link Existing Flights", systemImage: "link")
                    }
                    Button {
                        showAddFlight = true
                    } label: {
                        Label("Add New Flight", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(WandrTheme.accentTeal)
                }
            }

            ForEach(trip.sortedFlights, id: \.self) { flight in
                FlightCard(flight: flight)
                    .contextMenu {
                        Button {
                            flight.trip = nil
                            try? modelContext.save()
                        } label: {
                            Label("Unlink from Trip", systemImage: "link.badge.plus")
                        }
                        Button(role: .destructive) {
                            modelContext.delete(flight)
                        } label: {
                            Label("Delete Flight", systemImage: "trash")
                        }
                    }
            }
        }
    }

    // MARK: - Notes
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Notes")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            Text(notes)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - Actions
    private var actionsSection: some View {
        VStack(spacing: WandrTheme.spacingSM) {
            Button { showAddStop = true } label: {
                Label("Add City Stop", systemImage: "building.2.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
            }

            Button { showLinkFlights = true } label: {
                Label("Link Existing Flights", systemImage: "link")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WandrTheme.accentTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WandrTheme.accentTeal.opacity(0.1), in: RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
            }

            Button { showAddFlight = true } label: {
                Label("Add New Flight", systemImage: "airplane")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
            }
        }
    }
}

struct TimelineStopRow: View {
    let stop: TripStop
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: WandrTheme.spacingSM) {
            // Timeline connector
            VStack(spacing: 0) {
                Circle()
                    .fill(WandrTheme.accentTeal)
                    .frame(width: 12, height: 12)
                    .shadow(color: WandrTheme.accentTeal.opacity(0.4), radius: 4)

                if !isLast {
                    Rectangle()
                        .fill(WandrTheme.accentTeal.opacity(0.25))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            // Stop content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if let city = stop.city {
                        Text(city.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)

                        if let country = city.country {
                            Text(country.flagEmoji)
                                .font(.system(size: 14))
                        }
                    }
                    Spacer()
                    if let rating = stop.rating {
                        HStack(spacing: 2) {
                            ForEach(0..<rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(WandrTheme.accentAmber)
                            }
                        }
                    }
                }

                HStack(spacing: WandrTheme.spacingSM) {
                    if let arrival = stop.arrivalDate {
                        Text(arrival.dayMonth)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    if let departure = stop.departureDate {
                        Text("–").foregroundStyle(.tertiary)
                        Text(departure.dayMonth)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    if let duration = stop.durationDays {
                        Text("(\(duration)d)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }

                if let accommodation = stop.accommodation, !accommodation.isEmpty {
                    Label(accommodation, systemImage: "bed.double.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                if !stop.highlights.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(stop.highlights, id: \.self) { highlight in
                                Text(highlight)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(WandrTheme.accentTeal)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(WandrTheme.accentTeal.opacity(0.12), in: Capsule())
                            }
                        }
                    }
                }

                if let notes = stop.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }
            .glassCardDense()
        }
    }
}
