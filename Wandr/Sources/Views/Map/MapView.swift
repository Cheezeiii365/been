import SwiftUI
import MapKit
import SwiftData

struct TravelMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var countries: [Country]
    @Query private var cities: [City]
    @Query(sort: \Flight.departureTime) private var flights: [Flight]

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCity: City?
    @State private var showCityDetail = false
    @State private var mapFilter: MapFilter = .all

    enum MapFilter: String, CaseIterable {
        case all = "All"
        case cities = "Cities"
        case flights = "Flights"
    }

    var visitedCities: [City] { cities.filter { $0.isVisited } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $cameraPosition) {
                    // City markers
                    if mapFilter != .flights {
                        ForEach(visitedCities, id: \.id) { city in
                            Annotation(city.name, coordinate: CLLocationCoordinate2D(
                                latitude: city.latitude,
                                longitude: city.longitude
                            )) {
                                CityMapMarker(city: city)
                                    .onTapGesture {
                                        selectedCity = city
                                        showCityDetail = true
                                    }
                            }
                        }
                    }

                    // Flight routes
                    if mapFilter != .cities {
                        ForEach(flights, id: \.self) { flight in
                            MapPolyline(coordinates: [
                                CLLocationCoordinate2D(latitude: flight.departureLat, longitude: flight.departureLon),
                                CLLocationCoordinate2D(latitude: flight.arrivalLat, longitude: flight.arrivalLon)
                            ])
                            .stroke(WandrTheme.accentCyan.opacity(0.6), lineWidth: 2)
                        }
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .ignoresSafeArea(edges: .top)

                // Filter pills
                VStack {
                    Spacer().frame(height: 60)
                    HStack(spacing: WandrTheme.spacingSM) {
                        ForEach(MapFilter.allCases, id: \.self) { filter in
                            Button {
                                withAnimation { mapFilter = filter }
                            } label: {
                                Text(filter.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(mapFilter == filter ? WandrTheme.background : WandrTheme.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(mapFilter == filter ? WandrTheme.accentCyan : WandrTheme.surfaceSecondary.opacity(0.9))
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, WandrTheme.spacingMD)
                }

                // Bottom stats bar
                VStack {
                    Spacer()
                    HStack {
                        MiniStatBadge(label: "Countries", value: "\(countries.filter { $0.isVisited }.count)", color: WandrTheme.accentCyan)
                        Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
                        MiniStatBadge(label: "Cities", value: "\(visitedCities.count)", color: WandrTheme.accentPurple)
                        Divider().frame(height: 30).background(WandrTheme.surfaceTertiary)
                        MiniStatBadge(label: "Flights", value: "\(flights.count)", color: WandrTheme.accentBlue)
                    }
                    .padding(.vertical, WandrTheme.spacingSM)
                    .padding(.horizontal, WandrTheme.spacingMD)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusLG))
                    .padding(.horizontal, WandrTheme.spacingMD)
                    .padding(.bottom, 90)
                }
            }
            .sheet(isPresented: $showCityDetail) {
                if let city = selectedCity {
                    CityDetailSheet(city: city)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
            .navigationTitle("")
        }
    }
}

struct CityMapMarker: View {
    let city: City

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(WandrTheme.accentCyan)
                    .frame(width: 28, height: 28)
                    .shadow(color: WandrTheme.accentCyan.opacity(0.4), radius: 6)

                Image(systemName: "building.2.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct CityDetailSheet: View {
    let city: City

    var body: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingMD) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(WandrTheme.textPrimary)

                    if let country = city.country {
                        HStack(spacing: 4) {
                            Text(country.flagEmoji)
                            Text(country.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(WandrTheme.textSecondary)
                        }
                    }
                }
                Spacer()
            }

            Divider().background(WandrTheme.surfaceTertiary)

            // Stats
            HStack(spacing: WandrTheme.spacingLG) {
                VStack(spacing: 4) {
                    Text("\(city.totalVisits)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.accentCyan)
                    Text("Visits")
                        .font(.system(size: 12))
                        .foregroundStyle(WandrTheme.textTertiary)
                }

                VStack(spacing: 4) {
                    Text("\(city.totalDaysSpent)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.accentPurple)
                    Text("Days")
                        .font(.system(size: 12))
                        .foregroundStyle(WandrTheme.textTertiary)
                }

                if let first = city.firstVisited {
                    VStack(spacing: 4) {
                        Text(first.monthYear)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(WandrTheme.accentOrange)
                        Text("First Visit")
                            .font(.system(size: 12))
                            .foregroundStyle(WandrTheme.textTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Trip history
            if !city.tripStops.isEmpty {
                VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
                    Text("Trip History")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WandrTheme.textPrimary)

                    ForEach(city.tripStops.sorted(by: { ($0.arrivalDate ?? .distantPast) > ($1.arrivalDate ?? .distantPast) }), id: \.self) { stop in
                        HStack {
                            Circle()
                                .fill(WandrTheme.accentCyan)
                                .frame(width: 6, height: 6)

                            if let arrival = stop.arrivalDate {
                                Text(arrival.shortFormatted)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(WandrTheme.textSecondary)
                            }

                            Spacer()

                            Text(stop.durationDescription)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(WandrTheme.textTertiary)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(WandrTheme.spacingLG)
        .background(WandrTheme.surfacePrimary)
    }
}
