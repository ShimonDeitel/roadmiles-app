import Foundation

struct Trip: Identifiable, Codable, Equatable {
    let id: UUID
    var tripName: String
    var miles: Double
    var date: Date
    var stateOrCountry: String

    init(id: UUID = UUID(), tripName: String, miles: Double, date: Date, stateOrCountry: String) {
        self.id = id
        self.tripName = tripName
        self.miles = miles
        self.date = date
        self.stateOrCountry = stateOrCountry
    }
}
