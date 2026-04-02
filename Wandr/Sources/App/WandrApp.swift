import SwiftUI
import SwiftData

@main
struct WandrApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Country.self,
            City.self,
            Trip.self,
            TripStop.self,
            Flight.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    seedDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        CountryDataService.seed(modelContext: context)
    }
}
