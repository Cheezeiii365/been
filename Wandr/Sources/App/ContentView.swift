import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)

                TravelMapView()
                    .tag(1)

                TripsListView()
                    .tag(2)

                FlightsView()
                    .tag(3)

                StatsView()
                    .tag(4)

                SettingsView()
                    .tag(5)
            }
            .tabViewStyle(.automatic)

            // Custom tab bar
            customTabBar
        }
        .preferredColorScheme(.dark)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", label: "Home", tab: 0)
            tabButton(icon: "map.fill", label: "Map", tab: 1)
            tabButton(icon: "suitcase.fill", label: "Trips", tab: 2)
            tabButton(icon: "airplane", label: "Flights", tab: 3)
            tabButton(icon: "chart.bar.fill", label: "Stats", tab: 4)
            tabButton(icon: "gearshape.fill", label: "Settings", tab: 5)
        }
        .padding(.horizontal, WandrTheme.spacingSM)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            WandrTheme.surfacePrimary
                .overlay(
                    Rectangle()
                        .fill(WandrTheme.surfaceTertiary)
                        .frame(height: 0.5),
                    alignment: .top
                )
        )
    }

    private func tabButton(icon: String, label: String, tab: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                    .foregroundStyle(selectedTab == tab ? WandrTheme.accentCyan : WandrTheme.textTertiary)

                Text(label)
                    .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                    .foregroundStyle(selectedTab == tab ? WandrTheme.accentCyan : WandrTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
