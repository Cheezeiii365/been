import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                DashboardView()
            }

            Tab("Map", systemImage: "map.fill", value: 1) {
                TravelMapView()
            }

            Tab("Trips", systemImage: "suitcase.fill", value: 2) {
                TripsListView()
            }

            Tab("Flights", systemImage: "airplane", value: 3) {
                FlightsView()
            }

            Tab("Stats", systemImage: "chart.bar.fill", value: 4) {
                StatsView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 5) {
                SettingsView()
            }
        }
        .tint(WandrTheme.accentTeal)
    }
}

#Preview {
    ContentView()
}
