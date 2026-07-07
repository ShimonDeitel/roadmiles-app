import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: Trip?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.tripName)")
                                .font(Theme.headingFont)
                                .foregroundStyle(Theme.ink)
                            Text("\(item.miles)")
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.secondaryInk)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("itemRow_\(item.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .themedBackground()
            .navigationTitle("Roadmap Miles")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryEditorView(mode: .edit(item))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

enum EditorMode: Identifiable, Equatable {
    case add
    case edit(Trip)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mode: EditorMode

    @State private var draftTripname: String = ""
    @State private var draftMiles: Double = 0
    @State private var draftDate: Date = Date()
    @State private var draftStateorcountry: String = ""

    init(mode: EditorMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                TextField("Tripname", text: $draftTripname)
                    .accessibilityIdentifier("field_tripName")
                TextField("Miles", value: $draftMiles, format: .number)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("field_miles")
                DatePicker("Date", selection: $draftDate, displayedComponents: .date)
                    .accessibilityIdentifier("field_date")
                TextField("Stateorcountry", text: $draftStateorcountry)
                    .accessibilityIdentifier("field_stateOrCountry")
                }

                if case .edit(let item) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(item)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .themedBackground()
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edit" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftTripname = item.tripName
        draftMiles = item.miles
        draftDate = item.date
        draftStateorcountry = item.stateOrCountry
        } else {
        draftTripname = ""
        draftMiles = 0
        draftDate = Date()
        draftStateorcountry = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(Trip(tripName: draftTripname, miles: draftMiles, date: draftDate, stateOrCountry: draftStateorcountry))
        case .edit(let item):
            var updated = item
            updated.tripName = draftTripname
            updated.miles = draftMiles
            updated.date = draftDate
            updated.stateOrCountry = draftStateorcountry
            store.update(updated)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
