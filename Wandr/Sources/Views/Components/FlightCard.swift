import SwiftUI

struct FlightCard: View {
    let flight: Flight

    var body: some View {
        VStack(spacing: 0) {
            // Airline and flight number
            HStack {
                if let airline = flight.airline {
                    Text(airline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WandrTheme.textTertiary)
                }
                if let number = flight.flightNumber {
                    Text(number)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(WandrTheme.textSecondary)
                }
                Spacer()
                Text(flight.cabinClass.shortName)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(WandrTheme.accentCyan)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(WandrTheme.accentCyan.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.bottom, WandrTheme.spacingSM)

            // Route visualization (Flighty-style)
            HStack(alignment: .center, spacing: 0) {
                // Departure
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departureAirportCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(WandrTheme.textPrimary)
                    if let time = flight.departureTime {
                        Text(time.timeFormatted)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    if let name = flight.departureAirportName {
                        Text(name)
                            .font(.system(size: 10))
                            .foregroundStyle(WandrTheme.textTertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Flight path visualization
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(WandrTheme.accentCyan.opacity(0.3))
                            .frame(height: 1)
                        Image(systemName: "airplane")
                            .font(.system(size: 14))
                            .foregroundStyle(WandrTheme.accentCyan)
                            .rotationEffect(.degrees(0))
                        Rectangle()
                            .fill(WandrTheme.accentCyan.opacity(0.3))
                            .frame(height: 1)
                    }
                    Text(flight.durationDescription)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(WandrTheme.textTertiary)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // Arrival
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrivalAirportCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(WandrTheme.textPrimary)
                    if let time = flight.arrivalTime {
                        Text(time.timeFormatted)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(WandrTheme.textSecondary)
                    }
                    if let name = flight.arrivalAirportName {
                        Text(name)
                            .font(.system(size: 10))
                            .foregroundStyle(WandrTheme.textTertiary)
                            .lineLimit(1)
                    }
                }
            }

            // Date and status
            if let departureTime = flight.departureTime {
                Divider()
                    .background(WandrTheme.surfaceTertiary)
                    .padding(.vertical, WandrTheme.spacingSM)

                HStack {
                    Text(departureTime.shortFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WandrTheme.textTertiary)

                    Spacer()

                    Label(flight.status.rawValue, systemImage: flight.status.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(flight.status == .completed ? WandrTheme.accentGreen : WandrTheme.textSecondary)
                }
            }
        }
        .padding(WandrTheme.spacingMD)
        .background(WandrTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
    }
}
