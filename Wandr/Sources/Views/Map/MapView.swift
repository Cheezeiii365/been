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

                    if mapFilter != .cities {
                        ForEach(flights, id: \.self) { flight in
                            MapPolyline(coordinates: [
                                CLLocationCoordinate2D(latitude: flight.departureLat, longitude: flight.departureLon),
                                CLLocationCoordinate2D(latitude: flight.arrivalLat, longitude: flight.arrivalLon)
                            ])
                            .stroke(WandrTheme.accentTeal.opacity(0.6), lineWidth: 2)
                        }
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .ignoresSafeArea(edges: .top)

                // Filter pills — glass
                VStack {
                    Spacer().frame(height: 60)
                    HStack(spacing: WandrTheme.spacingSM) {
                        ForEach(MapFilter.allCases, id: \.self) { filter in
                            Button {
                                withAnimation { mapFilter = filter }
                            } label: {
                                Text(filter.rawValue)
                                    .foregroundStyle(mapFilter == filter ? .white : .primary)
                                    .glassPill(isActive: mapFilter == filter)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, WandrTheme.spacingMD)
                }

                // Bottom stats bar — glass
                VStack {
                    Spacer()
                    HStack {
                        MiniStatBadge(label: "Countries", value: "\(countries.filter { $0.isVisited }.count)", color: WandrTheme.accentTeal)
                        Divider().frame(height: 30)
                        MiniStatBadge(label: "Cities", value: "\(visitedCities.count)", color: WandrTheme.accentViolet)
                        Divider().frame(height: 30)
                        MiniStatBadge(label: "Flights", value: "\(flights.count)", color: WandrTheme.accentIndigo)
                    }
                    .padding(.vertical, WandrTheme.spacingSM)
                    .padding(.horizontal, WandrTheme.spacingMD)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusLG))
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
        ZStack {
            Circle()
                .fill(WandrTheme.accentTeal)
                .frame(width: 28, height: 28)
                .shadow(color: WandrTheme.accentTeal.opacity(0.5), radius: 8)

            Image(systemName: "building.2.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

struct CityDetailSheet: View {
    let city: City

    var body: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)

                    if let country = city.country {
                        HStack(spacing: 4) {
                            Text(country.flagEmoji)
                            Text(country.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
            }

            Divider()

            HStack(spacing: WandrTheme.spacingLG) {
                VStack(spacing: 4) {
                    Text("\(city.totalVisits)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.accentTeal)
                    Text("Visits")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                VStack(spacing: 4) {
                    Text("\(city.totalDaysSpent)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(WandrTheme.accentViolet)
                    Text("Days")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                if let first = city.firstVisited {
                    VStack(spacing: 4) {
                        Text(first.monthYear)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(WandrTheme.accentAmber)
                        Text("First Visit")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            if !city.tripStops.isEmpty {
                VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
                    Text("Trip History")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)

                    ForEach(city.tripStops.sorted(by: { ($0.arrivalDate ?? .distantPast) > ($1.arrivalDate ?? .distantPast) }), id: \.self) { stop in
                        HStack {
                            Circle()
                                .fill(WandrTheme.accentTeal)
                                .frame(width: 6, height: 6)

                            if let arrival = stop.arrivalDate {
                                Text(arrival.shortFormatted)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(stop.durationDescription)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(WandrTheme.spacingLG)
    }
}
