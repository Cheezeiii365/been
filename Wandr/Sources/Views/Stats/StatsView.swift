import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @Query private var countries: [Country]
    @Query private var cities: [City]
    @Query private var flights: [Flight]

    @State private var selectedYear: Int?

    var visitedCountries: [Country] { countries.filter { $0.isVisited } }
    var visitedCities: [City] { cities.filter { $0.isVisited } }

    private var availableYears: [Int] {
        let years = Set(trips.map { Calendar.current.component(.year, from: $0.startDate) })
        return years.sorted().reversed()
    }

    private var filteredTrips: [Trip] {
        guard let year = selectedYear else { return trips }
        return trips.filter { Calendar.current.component(.year, from: $0.startDate) == year }
    }

    private var totalDaysAbroad: Int {
        filteredTrips.reduce(0) { $0 + $1.durationDays }
    }

    private var totalMiles: Double {
        let relevantFlights = selectedYear == nil ? flights : flights.filter {
            guard let dt = $0.departureTime else { return false }
            return Calendar.current.component(.year, from: dt) == selectedYear
        }
        return relevantFlights.compactMap(\.distanceMiles).reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: WandrTheme.spacingLG) {
                    yearFilter
                    passportCard
                    metricsGrid
                    purposeBreakdown
                    topCountries
                    topCities
                    monthlyHeatmap
                    if !flights.isEmpty {
                        flightStats
                    }
                }
                .padding(.horizontal, WandrTheme.spacingMD)
                .padding(.bottom, 100)
            }
            .background { WandrTheme.warmMeshBackground() }
            .navigationTitle("Passport")
        }
    }

    // MARK: - Year Filter
    private var yearFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: WandrTheme.spacingSM) {
                Button { selectedYear = nil } label: {
                    Text("All Time")
                        .foregroundStyle(selectedYear == nil ? .white : .secondary)
                        .glassPill(isActive: selectedYear == nil)
                }

                ForEach(availableYears, id: \.self) { year in
                    Button { selectedYear = year } label: {
                        Text("\(year)")
                            .foregroundStyle(selectedYear == year ? .white : .secondary)
                            .glassPill(isActive: selectedYear == year)
                    }
                }
            }
        }
    }

    // MARK: - Passport Card
    private var passportCard: some View {
        VStack(spacing: WandrTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TRAVEL PASSPORT")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(WandrTheme.accentTeal.opacity(0.8))

                    Text(selectedYear != nil ? "\(selectedYear!)" : "All Time")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(WandrTheme.heroGradient)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f%%", Double(visitedCountries.count) / 195.0 * 100))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.accentTeal)
                    Text("of the world")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 6)
                        .frame(width: 70, height: 70)
                    Circle()
                        .trim(from: 0, to: CGFloat(visitedCountries.count) / 195.0)
                        .stroke(WandrTheme.heroGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                    Text("\(visitedCountries.count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }

            if !visitedCountries.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(visitedCountries, id: \.code) { country in
                            Text(country.flagEmoji)
                                .font(.system(size: 22))
                        }
                    }
                }
            }
        }
        .padding(WandrTheme.spacingLG)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusLG))
        .overlay(
            RoundedRectangle(cornerRadius: WandrTheme.radiusLG)
                .stroke(WandrTheme.accentTeal.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Metrics Grid
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: WandrTheme.spacingSM) {
            VStack(spacing: 4) {
                MiniStatBadge(label: "Trips", value: "\(filteredTrips.count)", color: WandrTheme.accentAmber)
            }
            .glassCard()

            VStack(spacing: 4) {
                MiniStatBadge(label: "Days", value: "\(totalDaysAbroad)", color: WandrTheme.accentTeal)
            }
            .glassCard()

            VStack(spacing: 4) {
                MiniStatBadge(
                    label: "Avg Trip",
                    value: filteredTrips.isEmpty ? "0" : String(format: "%.0f", Double(totalDaysAbroad) / Double(filteredTrips.count)),
                    color: WandrTheme.accentViolet
                )
            }
            .glassCard()
        }
    }

    // MARK: - Purpose Breakdown
    private var purposeBreakdown: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Trip Types")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            let purposeCounts = Dictionary(grouping: filteredTrips, by: \.purpose)
                .mapValues(\.count)
                .sorted { $0.value > $1.value }

            ForEach(purposeCounts, id: \.key) { purpose, count in
                HStack(spacing: WandrTheme.spacingSM) {
                    Image(systemName: purpose.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(WandrTheme.purposeColor(purpose))
                        .frame(width: 24)

                    Text(purpose.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(count)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(WandrTheme.purposeColor(purpose).opacity(0.4))
                            .frame(width: geo.size.width * CGFloat(count) / CGFloat(max(1, filteredTrips.count)), height: 4)
                    }
                    .frame(width: 60, height: 4)
                }
                .padding(.vertical, 4)
            }
        }
        .glassCard()
    }

    // MARK: - Top Countries
    private var topCountries: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Most Visited Countries")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            let countryCounts: [(Country, Int)] = {
                var counts: [String: (Country, Int)] = [:]
                for trip in filteredTrips {
                    for stop in trip.stops {
                        if let c = stop.city?.country {
                            counts[c.code, default: (c, 0)].1 += 1
                        }
                    }
                }
                return counts.values.sorted { $0.1 > $1.1 }
            }()

            ForEach(Array(countryCounts.prefix(5).enumerated()), id: \.offset) { index, item in
                HStack(spacing: WandrTheme.spacingSM) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .frame(width: 20)

                    Text(item.0.flagEmoji)
                        .font(.system(size: 20))

                    Text(item.0.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(item.1) visits")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if countryCounts.isEmpty {
                Text("No data yet")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
            }
        }
        .glassCard()
    }

    // MARK: - Top Cities
    private var topCities: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Most Visited Cities")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            let cityCounts: [(City, Int)] = {
                var counts: [String: (City, Int)] = [:]
                for trip in filteredTrips {
                    for stop in trip.stops {
                        if let c = stop.city {
                            counts[c.id, default: (c, 0)].1 += 1
                        }
                    }
                }
                return counts.values.sorted { $0.1 > $1.1 }
            }()

            ForEach(Array(cityCounts.prefix(5).enumerated()), id: \.offset) { index, item in
                HStack(spacing: WandrTheme.spacingSM) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .frame(width: 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                        if let country = item.0.country {
                            Text("\(country.flagEmoji) \(country.name)")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(item.1) visits")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text("\(item.0.totalDaysSpent)d total")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }

            if cityCounts.isEmpty {
                Text("No data yet")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
            }
        }
        .glassCard()
    }

    // MARK: - Monthly Heatmap
    private var monthlyHeatmap: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Travel Calendar")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            let monthNames = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
            let monthlyCounts: [Int] = {
                var counts = Array(repeating: 0, count: 12)
                for trip in filteredTrips {
                    let month = Calendar.current.component(.month, from: trip.startDate) - 1
                    counts[month] += 1
                }
                return counts
            }()
            let maxCount = monthlyCounts.max() ?? 1

            HStack(spacing: 6) {
                ForEach(0..<12, id: \.self) { month in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                monthlyCounts[month] > 0
                                    ? WandrTheme.accentTeal.opacity(Double(monthlyCounts[month]) / Double(maxCount))
                                    : .white.opacity(0.05)
                            )
                            .frame(height: 40)

                        Text(monthNames[month])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .glassCard()
    }

    // MARK: - Flight Stats
    private var flightStats: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            Text("Flight Stats")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: WandrTheme.spacingSM) {
                StatCard(title: "Total Flights", value: "\(flights.count)", icon: "airplane", color: WandrTheme.accentIndigo)
                StatCard(
                    title: "Miles Flown",
                    value: totalMiles > 1000 ? String(format: "%.0fk", totalMiles / 1000) : String(format: "%.0f", totalMiles),
                    icon: "globe",
                    color: WandrTheme.accentTeal
                )
            }

            let routeCounts: [(String, Int)] = {
                var counts: [String: Int] = [:]
                for flight in flights {
                    let route = flight.routeDescription
                    counts[route, default: 0] += 1
                }
                return counts.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
            }()

            if !routeCounts.isEmpty {
                Text("Top Routes")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.top, WandrTheme.spacingSM)

                ForEach(Array(routeCounts.prefix(3).enumerated()), id: \.offset) { _, route in
                    HStack {
                        Text(route.0)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(WandrTheme.accentTeal)
                        Spacer()
                        Text("\(route.1)x")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .glassCard()
    }
}
