import SwiftUI

struct FlightCard: View {
    let flight: Flight

    var body: some View {
        VStack(spacing: 0) {
            // Airline + cabin badge
            HStack {
                if let airline = flight.airline {
                    Text(airline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                if let number = flight.flightNumber {
                    Text(number)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(flight.cabinClass.shortName)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(WandrTheme.accentTeal)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(WandrTheme.accentTeal.opacity(0.15), in: Capsule())
            }
            .padding(.bottom, WandrTheme.spacingSM)

            // Route visualization
            HStack(alignment: .center, spacing: 0) {
                // Departure
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departureAirportCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                    if let time = flight.departureTime {
                        Text(time.timeFormatted)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    if let name = flight.departureAirportName {
                        Text(name)
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Flight path
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(WandrTheme.accentTeal.opacity(0.4))
                            .frame(height: 1)
                        Image(systemName: "airplane")
                            .font(.system(size: 14))
                            .foregroundStyle(WandrTheme.accentTeal)
                        Rectangle()
                            .fill(WandrTheme.accentTeal.opacity(0.4))
                            .frame(height: 1)
                    }
                    Text(flight.durationDescription)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // Arrival
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrivalAirportCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                    if let time = flight.arrivalTime {
                        Text(time.timeFormatted)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    if let name = flight.arrivalAirportName {
                        Text(name)
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }

            // Date + status footer
            if let departureTime = flight.departureTime {
                Divider()
                    .padding(.vertical, WandrTheme.spacingSM)

                HStack {
                    Text(departureTime.shortFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)

                    Spacer()

                    Label(flight.status.rawValue, systemImage: flight.status.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(statusColor)
                }
            }
        }
        .glassCard()
    }

    private var statusColor: Color {
        switch flight.status {
        case .completed: return WandrTheme.accentEmerald
        case .cancelled: return WandrTheme.accentRed
        case .delayed: return WandrTheme.accentAmber
        case .scheduled: return .secondary
        }
    }
}
