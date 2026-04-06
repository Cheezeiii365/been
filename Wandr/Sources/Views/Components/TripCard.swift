import SwiftUI

struct TripCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            // Header: purpose badge + live indicator
            HStack {
                Label(trip.purpose.rawValue, systemImage: trip.purpose.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WandrTheme.purposeColor(trip.purpose))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(WandrTheme.purposeColor(trip.purpose).opacity(0.15), in: Capsule())

                Spacer()

                if trip.isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(WandrTheme.accentEmerald)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(WandrTheme.accentEmerald)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(WandrTheme.accentEmerald.opacity(0.15), in: Capsule())
                }
            }

            // Title
            Text(trip.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            // Date range
            HStack(spacing: 4) {
                Text(trip.startDate.dayMonth)
                if let endDate = trip.endDate {
                    Text("–")
                    Text(endDate.dayMonth)
                } else {
                    Text("– ongoing")
                }
            }
            .font(.system(size: 13, weight: .medium, design: .monospaced))
            .foregroundStyle(.secondary)

            // Stats row
            HStack(spacing: WandrTheme.spacingMD) {
                if trip.countryCount > 0 {
                    Label("\(trip.countryCount)", systemImage: "flag.fill")
                }
                if trip.cityCount > 0 {
                    Label("\(trip.cityCount)", systemImage: "building.2.fill")
                }
                Label("\(trip.durationDays)d", systemImage: "calendar")
                if !trip.flights.isEmpty {
                    Label("\(trip.flights.count)", systemImage: "airplane")
                }
                Spacer()
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.tertiary)

            // City dots
            if !trip.sortedStops.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(trip.sortedStops, id: \.self) { stop in
                            if let city = stop.city {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(WandrTheme.accentTeal)
                                        .frame(width: 5, height: 5)
                                    Text(city.name)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .glassCard()
    }
}
