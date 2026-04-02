import SwiftUI

struct TripCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            // Header with purpose badge
            HStack {
                Label(trip.purpose.rawValue, systemImage: trip.purpose.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WandrTheme.purposeColor(trip.purpose))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(WandrTheme.purposeColor(trip.purpose).opacity(0.15))
                    .clipShape(Capsule())

                Spacer()

                if trip.isActive {
                    Text("LIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WandrTheme.accentGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(WandrTheme.accentGreen.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            // Title
            Text(trip.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WandrTheme.textPrimary)

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
            .foregroundStyle(WandrTheme.textSecondary)

            // Bottom stats row
            HStack(spacing: WandrTheme.spacingMD) {
                if trip.countryCount > 0 {
                    Label("\(trip.countryCount)", systemImage: "flag.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WandrTheme.textTertiary)
                }

                if trip.cityCount > 0 {
                    Label("\(trip.cityCount)", systemImage: "building.2.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WandrTheme.textTertiary)
                }

                Label("\(trip.durationDays)d", systemImage: "calendar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WandrTheme.textTertiary)

                if !trip.flights.isEmpty {
                    Label("\(trip.flights.count)", systemImage: "airplane")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WandrTheme.textTertiary)
                }

                Spacer()
            }

            // City timeline dots
            if !trip.sortedStops.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(trip.sortedStops, id: \.self) { stop in
                            if let city = stop.city {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(WandrTheme.accentCyan)
                                        .frame(width: 6, height: 6)
                                    Text(city.name)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(WandrTheme.textSecondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(WandrTheme.spacingMD)
        .background(WandrTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
    }
}
