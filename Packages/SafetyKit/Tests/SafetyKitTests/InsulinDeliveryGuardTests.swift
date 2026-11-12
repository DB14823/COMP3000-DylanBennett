import Domain
import Foundation
import PumpPort
import Testing

@testable import SafetyKit

@Suite("InsulinDeliveryGuard")
struct InsulinDeliveryGuardTests {
    private actor RecordingPump: PumpDriver {
        private(set) var deliveryCallCount = 0

        func status() async -> PumpStatus {
            .ready
        }

        func deliver(_ request: DoseRequest) async -> DeliveryResult {
            deliveryCallCount += 1

            return .uncertain(
                requestID: request.id,
                recordedAt: request.createdAt
            )
        }

        func reconcile(requestID: UUID) async -> DeliveryResult {
            .uncertain(
                requestID: requestID,
                recordedAt: Date(timeIntervalSince1970: 1_700_000_000)
            )
        }
    }

    @Test
    func rejectsOversizedBolusWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let limits = SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 10.0)
        )
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: InsulinUnits(units: 3.0),
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        await #expect(throws: SafetyRejection.bolusLimitExceeded) {
            try await deliveryGuard.deliver(request)
        }

        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }

    @Test
    func rejectsMissingContextAtBolusLimitWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let limits = SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 10.0)
        )
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: InsulinUnits(units: 2.0),
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        await #expect(throws: SafetyRejection.invalidContext) {
            try await deliveryGuard.deliver(request)
        }

        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }
}
