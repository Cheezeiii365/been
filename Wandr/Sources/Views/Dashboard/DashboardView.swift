import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @Query private var countries: [Country]
    @Query private var cities: [City]
    @Query(sort: \Flight.departureTime, order: .reverse) private var flights: [Flight]

    var visitedCountries: [Country] { countries.filter { $0.isVisited } }
    var visitedCities: [City] { cities.filter { $0.isVisited } }
    var activeTrip: Trip? { trips.first { $0.isActive } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: WandrTheme.spacingMD) {
                    // Hero header
                    heroHeader

                    // Active trip banner
                    if let activeTrip {
                        activeTripBanner(activeTrip)
                    }

                    // Quick stats grid
                    statsGrid

                    // Recent trips
                    if !trips.isEmpty {
                        recentTripsSection
                    }

                    // Upcoming flights
                    let upcomingFlights = flights.filter { ($0.departureTime ?? .distantPast) > Date() }
                    if !upcomingFlights.isEmpty {
                        upcomingFlightsSection(upcomingFlights)
                    }

                    // Continent progress
                    continentProgress
                }
                .padding(.horizontal, WandrTheme.spacingMD)
                .padding(.bottom, 100)
            }
            .background(WandrTheme.background)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Wandr")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.heroGradient)
                }
            }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: WandrTheme.spacingLG) {
            // World coverage ring
            ZStack {
                Circle()
                    .stroke(WandrTheme.surfaceTertiary, lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(visitedCountries.count) / 195.0)
                    .stroke(
                        WandrTheme.heroGradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(visitedCountries.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.textPrimary)
                    Text("of 195")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WandrTheme.textTertiary)
                }
            }

            Text(String(format: "%.1f%% of the world explored", Double(visitedCountries.count) / 195.0 * 100))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WandrTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WandrTheme.spacingLG)
    }

    // MARK: - Active Trip
    private func activeTripBanner(_ trip: Trip) -> some View {
        NavigationLink(destination: TripDetailView(trip: trip)) {
            HStack(spacing: WandrTheme.spacingSM) {
                Circle()
                    .fill(WandrTheme.accentGreen)
                    .frame(width: 8, height: 8)
                    .shadow(color: WandrTheme.accentGreen.opacity(0.5), radius: 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Currently traveling")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(WandrTheme.accentGreen)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text(trip.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WandrTheme.textPrimary)
                }

                Spacer()

                Text("Day \(trip.durationDays)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(WandrTheme.accentGreen)
            }
            .padding(WandrTheme.spacingMD)
            .background(WandrTheme.accentGreen.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: WandrTheme.radiusMD)
                    .stroke(WandrTheme.accentGreen.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
        }
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: WandrTheme.spacingSM) {
            StatCard(
                title: "Countries",
                value: "\(visitedCountries.count)",
                icon: "flag.fill",
                color: WandrTheme.accentCyan
            )

            StatCard(
                title: "Cities",
                value: "\(visitedCities.count)",
                icon: "building.2.fill",
                color: WandrTheme.accentPurple
            )

            StatCard(
                title: "Trips",
                value: "\(trips.count)",
                icon: "suitcase.fill",
                color: WandrTheme.accentOrange
            )

            StatCard(
                title: "Flights",
                value: "\(flights.count)",
                icon: "airplane",
                color: WandrTheme.accentBlue
            )
        }
    }

    // MARK: - Recent Trips
    private var recentTripsSection: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Text("Recent Trips")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WandrTheme.textPrimary)
                Spacer()
                NavigationLink("See All") {
                    TripsListView()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WandrTheme.accentCyan)
            }

            ForEach(Array(trips.prefix(3)), id: \.self) { trip in
                NavigationLink(destination: TripDetailView(trip: trip)) {
                    TripCard(trip: trip)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Upcoming Flights
    private func upcomingFlightsSection(_ upcomingFlights: [Flight]) -> some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Upcoming Flights")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WandrTheme.textPrimary)

            ForEach(Array(upcomingFlights.prefix(2)), id: \.self) { flight in
                FlightCard(flight: flight)
            }
        }
    }

    // MARK: - Continent Progress
    private var continentProgress: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Continent Coverage")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WandrTheme.textPrimary)

            let continentCounts: [(Continent, Int)] = {
                var counts: [Continent: Int] = [:]
                for country in visitedCountries {
                    counts[country.continent, default: 0] += 1
                }
                return Continent.allCases.map { ($0, counts[$0] ?? 0) }
            }()

            ForEach(continentCounts, id: \.0) { continent, count in
                ContinentRow(continent: continent, visitedCount: count)
            }
        }
        .wandrCard()
    }
}

struct ContinentRow: View {
    let continent: Continent
    let visitedCount: Int

    private var totalCountries: Int {
        switch continent {
        case .africa: return 54
        case .antarctica: return 0
        case .asia: return 49
        case .europe: return 44
        case .northAmerica: return 23
        case .southAmerica: return 12
        case .oceania: return 14
        }
    }

    var body: some View {
        HStack(spacing: WandrTheme.spacingSM) {
            Text(continent.emoji)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(continent.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WandrTheme.textPrimary)
                    Spacer()
                    Text("\(visitedCount)/\(totalCountries)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(WandrTheme.textSecondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(WandrTheme.surfaceTertiary)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(WandrTheme.heroGradient)
                            .frame(width: totalCountries > 0 ? geo.size.width * CGFloat(visitedCount) / CGFloat(totalCountries) : 0, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 4)
    }
}
