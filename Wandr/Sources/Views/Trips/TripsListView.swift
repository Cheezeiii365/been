import SwiftUI
import SwiftData

struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @State private var showAddTrip = false
    @State private var searchText = ""
    @State private var filterPurpose: TripPurpose?
    @State private var filterYear: Int?

    private var filteredTrips: [Trip] {
        trips.filter { trip in
            let matchesSearch = searchText.isEmpty || trip.title.localizedCaseInsensitiveContains(searchText)
            let matchesPurpose = filterPurpose == nil || trip.purpose == filterPurpose
            let matchesYear = filterYear == nil || Calendar.current.component(.year, from: trip.startDate) == filterYear
            return matchesSearch && matchesPurpose && matchesYear
        }
    }

    private var availableYears: [Int] {
        let years = Set(trips.map { Calendar.current.component(.year, from: $0.startDate) })
        return years.sorted().reversed()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: WandrTheme.spacingMD) {
                    filtersSection

                    HStack {
                        Text("\(filteredTrips.count) trips")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }

                    if filteredTrips.isEmpty {
                        emptyState
                    } else {
                        ForEach(filteredTrips, id: \.self) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip)) {
                                TripCard(trip: trip)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, WandrTheme.spacingMD)
                .padding(.bottom, 100)
            }
            .background { WandrTheme.meshBackground() }
            .navigationTitle("Trips")
            .searchable(text: $searchText, prompt: "Search trips...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddTrip = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(WandrTheme.accentTeal)
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddTrip) {
                AddTripView()
            }
        }
    }

    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: WandrTheme.spacingSM) {
                Menu {
                    Button("All Years") { filterYear = nil }
                    ForEach(availableYears, id: \.self) { year in
                        Button("\(year)") { filterYear = year }
                    }
                } label: {
                    Text(filterYear != nil ? "\(filterYear!)" : "Year")
                        .foregroundStyle(filterYear != nil ? .white : .secondary)
                        .glassPill(isActive: filterYear != nil)
                }

                Menu {
                    Button("All Types") { filterPurpose = nil }
                    ForEach(TripPurpose.allCases) { purpose in
                        Button {
                            filterPurpose = purpose
                        } label: {
                            Label(purpose.rawValue, systemImage: purpose.icon)
                        }
                    }
                } label: {
                    Text(filterPurpose?.rawValue ?? "Type")
                        .foregroundStyle(filterPurpose != nil ? .white : .secondary)
                        .glassPill(isActive: filterPurpose != nil)
                }

                if filterYear != nil || filterPurpose != nil {
                    Button {
                        filterYear = nil
                        filterPurpose = nil
                    } label: {
                        Text("Clear")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WandrTheme.accentRed)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: WandrTheme.spacingMD) {
            Image(systemName: "suitcase")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("No trips yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            Text("Tap + to log your first trip")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
