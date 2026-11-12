import Foundation
import Testing

@testable import Domain

@Suite("DeliveryResult")
struct DeliveryResultTests {
    @Test
    func storesConfirmedDeliveryDetails() throws {
        let requestID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000001"
        )!
        let amount = try InsulinUnits(units: 1.25)
        let completedAt = Date(timeIntervalSince1970: 1_700_000_000)

        let result = DeliveryResult.confirmed(
            requestID: requestID,
            deliveredAmount: amount,
            completedAt: completedAt
        )

        guard
            case .confirmed(
                let storedID,
                let storedAmount,
                let storedTime
            ) = result
        else {
            Issue.record("Expected a confirmed delivery outcome")
            return
        }

        #expect(storedID == requestID)
        #expect(storedAmount == amount)
        #expect(storedTime == completedAt)
    }
    @Test
    func preservesUncertainOutcome() {
        let requestID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000001"
        )!
        let recordedAt = Date(timeIntervalSince1970: 1_700_000_000)

        let result = DeliveryResult.uncertain(
            requestID: requestID,
            recordedAt: recordedAt
        )

        guard
            case .uncertain(
                let storedID,
                let storedTime
            ) = result
        else {
            Issue.record("Uncertain delivery must remain uncertain")
            return
        }

        #expect(storedID == requestID)
        #expect(storedTime == recordedAt)
    }
}
