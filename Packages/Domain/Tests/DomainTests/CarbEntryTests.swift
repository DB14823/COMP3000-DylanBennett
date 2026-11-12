import Foundation
import Testing

@testable import Domain

@Suite("CarbEntry")
struct CarbEntryTests {
    @Test
    func storesCarbohydrateEntryDetails() throws {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let amount = try Carbs(grams: 30.0)
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

        let entry = CarbEntry(
            id: id,
            amount: amount,
            timestamp: timestamp
        )

        #expect(entry.id == id)
        #expect(entry.amount == amount)
        #expect(entry.timestamp == timestamp)
    }
}
