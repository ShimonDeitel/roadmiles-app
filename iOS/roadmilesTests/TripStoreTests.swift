import XCTest
@testable import roadmiles

@MainActor
final class TripStoreTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(Trip(tripName: "Sample Tripname 10", miles: 125.00, date: Date().addingTimeInterval(-2592000), stateOrCountry: "Sample Stateorcountry 10"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddBeyondFreeLimitIsBlocked() {
        while store.canAddMore {
            store.add(Trip(tripName: "Sample Tripname 2", miles: 25.00, date: Date().addingTimeInterval(-518400), stateOrCountry: "Sample Stateorcountry 2"))
        }
        let countAtLimit = store.items.count
        store.add(Trip(tripName: "Sample Tripname 3", miles: 37.50, date: Date().addingTimeInterval(-777600), stateOrCountry: "Sample Stateorcountry 3"))
        XCTAssertEqual(store.items.count, countAtLimit)
    }

    func testProUnlockBypassesLimit() {
        while store.canAddMore {
            store.add(Trip(tripName: "Sample Tripname 2", miles: 25.00, date: Date().addingTimeInterval(-518400), stateOrCountry: "Sample Stateorcountry 2"))
        }
        store.isProUnlocked = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesItem() {
        let item = store.items[0]
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testUpdateModifiesItem() {
        var item = store.items[0]
        item.tripName = "Sample Tripname 6"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.tripName, item.tripName)
    }

    func testDeleteAtOffsetsRemovesCorrectItem() {
        let target = store.items[0]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertFalse(store.items.contains(target))
    }
}
