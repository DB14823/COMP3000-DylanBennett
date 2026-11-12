import Foundation
import Testing

@testable import Domain

@Suite("DoseEvent")
struct DoseEventTests {
    @Test
    func storesDeliveredDoseDetails() throws {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let amount = try InsulinUnits(units: 1.25)
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

        let event = DoseEvent(
            id: id,
            amount: amount,
            timestamp: timestamp
        )

        #expect(event.id == id)
        #expect(event.amount == amount)
        #expect(event.timestamp == timestamp)
    }

    @Test
    func compareEquality() throws {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let amount = try InsulinUnits(units: 1.25)
        let diffAmount = try InsulinUnits(units: 1.5)
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let diffID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000002"
        )!

        let first = DoseEvent(
            id: id,
            amount: amount,
            timestamp: timestamp
        )

        let identical = DoseEvent(
            id: id,
            amount: amount,
            timestamp: timestamp
        )

        let differentID = DoseEvent(
            id: diffID,
            amount: amount,
            timestamp: timestamp
        )

        let differentAmount = DoseEvent(
            id: id,
            amount: diffAmount,
            timestamp: timestamp
        )

        let differentTime = DoseEvent(
            id: id,
            amount: amount,
            timestamp: timestamp.addingTimeInterval(60)
        )

        #expect(first != differentTime)
        #expect(first != differentAmount)
        #expect(first != differentID)
        #expect(first == identical)
    }
}
