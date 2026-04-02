import SwiftUI
import SwiftData

struct FlightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flight.departureTime, order: .reverse) private var flights: [Flight]
    @State private var showAddFlight = false
    @State private var filterStatus: FlightStatus?

    var filteredFlights: [Flight] {
        guard let status = filterStatus else { return flights }
        return flights.filter { $0.status == status }
    }

    var upcomingFlights: [Flight] {
        flights.filter { ($0.departureTime ?? .distantPast) > Date() }
    }

    var completedFlights: [Flight] {
        flights.filter { $0.status == .completed }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: WandrTheme.spacingMD) {
                    // Flight summary strip
                    flightSummary

                    // Status filter
                    statusFilter

                    // Flights list
                    if filteredFlights.isEmpty {
                        emptyState
                    } else {
                        ForEach(filteredFlights, id: \.self) { flight in
                            FlightCard(flight: flight)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        modelContext.delete(flight)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, WandrTheme.spacingMD)
                .padding(.bottom, 100)
            }
            .background(WandrTheme.background)
            .navigationTitle("Flights")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddFlight = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(WandrTheme.accentCyan)
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddFlight) {
                AddFlightView(trip: nil)
            }
        }
    }

    // MARK: - Summary
    private var flightSummary: some View {
        HStack {
            MiniStatBadge(label: "Total", value: "\(flights.count)", color: WandrTheme.accentBlue)
            Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
            MiniStatBadge(label: "Upcoming", value: "\(upcomingFlights.count)", color: WandrTheme.accentOrange)
            Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
            MiniStatBadge(label: "Completed", value: "\(completedFlights.count)", color: WandrTheme.accentGreen)
        }
        .wandrCard()
    }

    // MARK: - Status Filter
    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: WandrTheme.spacingSM) {
                Button {
                    filterStatus = nil
                } label: {
                    Text("All")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(filterStatus == nil ? WandrTheme.background : WandrTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(filterStatus == nil ? WandrTheme.accentCyan : WandrTheme.surfaceSecondary)
                        .clipShape(Capsule())
                }

                ForEach(FlightStatus.allCases) { status in
                    Button {
                        filterStatus = status
                    } label: {
                        Label(status.rawValue, systemImage: status.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(filterStatus == status ? WandrTheme.background : WandrTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(filterStatus == status ? WandrTheme.accentCyan : WandrTheme.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: WandrTheme.spacingMD) {
            Image(systemName: "airplane")
                .font(.system(size: 48))
                .foregroundStyle(WandrTheme.textTertiary)

            Text("No flights logged")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WandrTheme.textPrimary)

            Text("Tap + to add your first flight")
                .font(.system(size: 14))
                .foregroundStyle(WandrTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
