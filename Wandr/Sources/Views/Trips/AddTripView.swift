import SwiftUI
import SwiftData

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasEndDate = false
    @State private var purpose: TripPurpose = .leisure
    @State private var notes = ""
    @State private var isActive = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Trip Name", text: $title)
                        .font(.system(size: 16, weight: .medium))

                    Picker("Purpose", selection: $purpose) {
                        ForEach(TripPurpose.allCases) { p in
                            Label(p.rawValue, systemImage: p.icon).tag(p)
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Has End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                    Toggle("Currently Active", isOn: $isActive)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTrip() }
                        .disabled(title.isEmpty)
                        .foregroundStyle(title.isEmpty ? Color.gray : WandrTheme.accentTeal)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func saveTrip() {
        let trip = Trip(
            title: title,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            notes: notes.isEmpty ? nil : notes,
            purpose: purpose,
            isActive: isActive
        )
        modelContext.insert(trip)
        try? modelContext.save()
        dismiss()
    }
}

struct EditTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: Trip

    @State private var title: String = ""
    @State private var purpose: TripPurpose = .leisure
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var hasEndDate: Bool = false
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Trip Name", text: $title)
                    Picker("Purpose", selection: $purpose) {
                        ForEach(TripPurpose.allCases) { p in
                            Label(p.rawValue, systemImage: p.icon).tag(p)
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Has End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        trip.title = title
                        trip.purpose = purpose
                        trip.startDate = startDate
                        trip.endDate = hasEndDate ? endDate : nil
                        trip.notes = notes.isEmpty ? nil : notes
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(WandrTheme.accentTeal)
                }
            }
            .onAppear {
                title = trip.title
                purpose = trip.purpose
                startDate = trip.startDate
                hasEndDate = trip.endDate != nil
                endDate = trip.endDate ?? Date()
                notes = trip.notes ?? ""
            }
        }
    }
}
