import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Trip] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier item cap. Deliberately kept above the seed data count
    /// so a fresh install never opens directly into the paywall.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("roadmiles_items.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: Trip) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Trip) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Trip) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Trip].self, from: data) {
            items = decoded
        } else {
            items = [
        Trip(tripName: "Sample Tripname 1", miles: 12.50, date: Date().addingTimeInterval(-259200), stateOrCountry: "Sample Stateorcountry 1"),
        Trip(tripName: "Sample Tripname 2", miles: 25.00, date: Date().addingTimeInterval(-518400), stateOrCountry: "Sample Stateorcountry 2"),
        Trip(tripName: "Sample Tripname 3", miles: 37.50, date: Date().addingTimeInterval(-777600), stateOrCountry: "Sample Stateorcountry 3")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
