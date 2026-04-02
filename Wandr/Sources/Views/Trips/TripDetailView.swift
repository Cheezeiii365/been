import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: Trip
    @State private var showAddStop = false
    @State private var showAddFlight = false
    @State private var showEditTrip = false

    var body: some View {
        ScrollView {
            VStack(spacing: WandrTheme.spacingMD) {
                // Trip header
                tripHeader

                // Quick stats
                tripQuickStats

                // Timeline
                if !trip.sortedStops.isEmpty {
                    timelineSection
                }

                // Flights
                if !trip.sortedFlights.isEmpty {
                    flightsSection
                }

                // Notes
                if let notes = trip.notes, !notes.isEmpty {
                    notesSection(notes)
                }

                // Actions
                actionsSection
            }
            .padding(.horizontal, WandrTheme.spacingMD)
            .padding(.bottom, 100)
        }
        .background(WandrTheme.background)
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
                        .foregroundStyle(WandrTheme.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showAddStop) {
            AddStopView(trip: trip)
        }
        .sheet(isPresented: $showAddFlight) {
            AddFlightView(trip: trip)
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
                    .background(WandrTheme.purposeColor(trip.purpose).opacity(0.15))
                    .clipShape(Capsule())

                if trip.isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(WandrTheme.accentGreen)
                            .frame(width: 6, height: 6)
                        Text("ACTIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(WandrTheme.accentGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(WandrTheme.accentGreen.opacity(0.15))
                    .clipShape(Capsule())
                }
            }

            Text(trip.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(WandrTheme.textPrimary)

            HStack(spacing: WandrTheme.spacingSM) {
                Image(systemName: "calendar")
                    .foregroundStyle(WandrTheme.accentCyan)
                Text(trip.startDate.shortFormatted)
                if let end = trip.endDate {
                    Text("–")
                    Text(end.shortFormatted)
                } else {
                    Text("– present")
                }
            }
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundStyle(WandrTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, WandrTheme.spacingSM)
    }

    // MARK: - Quick Stats
    private var tripQuickStats: some View {
        HStack {
            MiniStatBadge(label: "Days", value: "\(trip.durationDays)", color: WandrTheme.accentCyan)
            Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
            MiniStatBadge(label: "Countries", value: "\(trip.countryCount)", color: WandrTheme.accentPurple)
            Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
            MiniStatBadge(label: "Cities", value: "\(trip.cityCount)", color: WandrTheme.accentOrange)
            Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
            MiniStatBadge(label: "Flights", value: "\(trip.flights.count)", color: WandrTheme.accentBlue)
        }
        .wandrCard()
    }

    // MARK: - Timeline
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Text("Timeline")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WandrTheme.textPrimary)
                Spacer()
                Button {
                    showAddStop = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(WandrTheme.accentCyan)
                }
            }

            ForEach(Array(trip.sortedStops.enumerated()), id: \.element) { index, stop in
                TimelineStopRow(stop: stop, isLast: index == trip.sortedStops.count - 1)
            }
        }
    }

    // MARK: - Flights
    private var flightsSection: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Text("Flights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WandrTheme.textPrimary)
                Spacer()
                Button {
                    showAddFlight = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(WandrTheme.accentCyan)
                }
            }

            ForEach(trip.sortedFlights, id: \.self) { flight in
                FlightCard(flight: flight)
            }
        }
    }

    // MARK: - Notes
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Notes")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WandrTheme.textPrimary)

            Text(notes)
                .font(.system(size: 14))
                .foregroundStyle(WandrTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wandrCard()
    }

    // MARK: - Actions
    private var actionsSection: some View {
        VStack(spacing: WandrTheme.spacingSM) {
            Button {
                showAddStop = true
            } label: {
                Label("Add City Stop", systemImage: "building.2.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WandrTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WandrTheme.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
            }

            Button {
                showAddFlight = true
            } label: {
                Label("Add Flight", systemImage: "airplane")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WandrTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WandrTheme.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
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
                    .fill(WandrTheme.accentCyan)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(WandrTheme.accentCyan.opacity(0.3))
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
                            .foregroundStyle(WandrTheme.textPrimary)

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
                                    .foregroundStyle(WandrTheme.accentOrange)
                            }
                        }
                    }
                }

                HStack(spacing: WandrTheme.spacingSM) {
                    if let arrival = stop.arrivalDate {
                        Text(arrival.dayMonth)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    if let departure = stop.departureDate {
                        Text("–")
                            .foregroundStyle(WandrTheme.textTertiary)
                        Text(departure.dayMonth)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    if let duration = stop.durationDays {
                        Text("(\(duration)d)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WandrTheme.textTertiary)
                    }
                }

                if let accommodation = stop.accommodation, !accommodation.isEmpty {
                    Label(accommodation, systemImage: "bed.double.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(WandrTheme.textTertiary)
                }

                if !stop.highlights.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(stop.highlights, id: \.self) { highlight in
                                Text(highlight)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(WandrTheme.accentCyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(WandrTheme.accentCyan.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                if let notes = stop.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundStyle(WandrTheme.textTertiary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, WandrTheme.spacingSM)
            .padding(.horizontal, WandrTheme.spacingSM)
            .background(WandrTheme.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusSM))
        }
    }
}
