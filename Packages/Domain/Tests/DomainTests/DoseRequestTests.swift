import Foundation
import Testing

@testable import Domain

@Suite("DoseRequest")
struct DoseRequestTests {
    @Test
    func storesBolusRequestDetails() throws {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let amount = try InsulinUnits(units: 1.25)
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)

        let request = try DoseRequest(
            id: id,
            amount: amount,
            createdAt: createdAt
        )

        #expect(request.id == id)
        #expect(request.amount == amount)
        #expect(request.createdAt == createdAt)
    }

    @Test
    func rejectsZeroAmount() throws {
        let amount = try InsulinUnits(units: 0)
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)

        #expect(throws: DoseRequestError.zeroAmount) {
            try DoseRequest(
                id: UUID(),
                amount: amount,
                createdAt: createdAt
            )
        }
    }
}
