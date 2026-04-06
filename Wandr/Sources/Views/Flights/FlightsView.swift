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
                    flightSummary
                    statusFilter

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
            .background { WandrTheme.meshBackground() }
            .navigationTitle("Flights")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddFlight = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(WandrTheme.accentTeal)
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
            MiniStatBadge(label: "Total", value: "\(flights.count)", color: WandrTheme.accentIndigo)
            Divider().frame(height: 30)
            MiniStatBadge(label: "Upcoming", value: "\(upcomingFlights.count)", color: WandrTheme.accentAmber)
            Divider().frame(height: 30)
            MiniStatBadge(label: "Completed", value: "\(completedFlights.count)", color: WandrTheme.accentEmerald)
        }
        .glassCard()
    }

    // MARK: - Status Filter
    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: WandrTheme.spacingSM) {
                Button { filterStatus = nil } label: {
                    Text("All")
                        .foregroundStyle(filterStatus == nil ? .white : .secondary)
                        .glassPill(isActive: filterStatus == nil)
                }

                ForEach(FlightStatus.allCases) { status in
                    Button { filterStatus = status } label: {
                        Label(status.rawValue, systemImage: status.icon)
                            .foregroundStyle(filterStatus == status ? .white : .secondary)
                            .glassPill(isActive: filterStatus == status)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: WandrTheme.spacingMD) {
            Image(systemName: "airplane")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("No flights logged")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            Text("Tap + to add your first flight")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
