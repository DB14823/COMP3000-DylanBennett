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

    private struct FixedClock: LoopClock {
        let date: Date
        func now() -> Date {
            return date
        }
    }

    private actor UnavailableHistory: DoseHistorySource {
        private(set) var readCallCount = 0
        func history(
            from start: Date,
            through end: Date
        ) async -> DoseHistoryAvailability {
            readCallCount += 1

            return .unavailable
        }
    }

    private struct AvailableHistory: DoseHistorySource {
        let snapshot: DoseHistorySnapshot
        func history(
            from start: Date,
            through end: Date
        ) async -> DoseHistoryAvailability {
            return .available(snapshot)
        }

    }

    @Test
    func rejectsOversizedBolusWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 10.0),
            historyLookback: 600.0
        )
        let clock = FixedClock(
            date: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: UnavailableHistory()
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
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 10.0),
            historyLookback: 600.0
        )
        let clock = FixedClock(
            date: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: UnavailableHistory()
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

    @Test
    func rejectsFutureRequestWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 10.0),
            historyLookback: 600.0
        )
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedClock(date: now)
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: UnavailableHistory()
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            createdAt: now.addingTimeInterval(60)
        )

        await #expect(throws: SafetyRejection.invalidRequestTime) {
            try await deliveryGuard.deliver(request)
        }
        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }

    @Test
    func rejectsUnavailableHistoryWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let historySource = UnavailableHistory()
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 3.0),
            historyLookback: 600.0
        )
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedClock(date: now)
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: historySource
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            createdAt: now
        )

        await #expect(throws: SafetyRejection.invalidContext) {
            try await deliveryGuard.deliver(request)
        }
        let history = await historySource.readCallCount
        #expect(history == 1)
        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }

    @Test
    func rejectsPendingDeliveryWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedClock(date: now)
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 3.0),
            historyLookback: 600.0
        )
        let pendingID = UUID()
        let otherID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000003"
        )!
        let snapshot = try DoseHistorySnapshot(
            events: [],
            coverageStart: now.addingTimeInterval(-600),
            coverageEnd: now,
            pendingRequestIDs: [pendingID]
        )
        let historySource = AvailableHistory(snapshot: snapshot)
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: historySource
        )
        let request = try DoseRequest(
            id: otherID,
            amount: try InsulinUnits(units: 1.0),
            createdAt: now
        )

        await #expect(throws: SafetyRejection.deliveryPending) {
            try await deliveryGuard.deliver(request)
        }
        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }

    @Test
    func rejectsInsufficientHistoryWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedClock(date: now)
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 3.0),
            historyLookback: 600.0
        )
        let snapshot = try DoseHistorySnapshot(
            events: [],
            coverageStart: now.addingTimeInterval(-300),
            coverageEnd: now,
            pendingRequestIDs: []
        )
        let historySource = AvailableHistory(snapshot: snapshot)
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: historySource
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            createdAt: now
        )

        await #expect(throws: SafetyRejection.insufficientHistory) {
            try await deliveryGuard.deliver(request)
        }
        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }

    @Test
    func rejectsHistoryEndingTooEarlyWithoutCallingPump() async throws {
        let pump = RecordingPump()
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedClock(date: now)
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 3.0),
            historyLookback: 600.0
        )
        let snapshot = try DoseHistorySnapshot(
            events: [],
            coverageStart: now.addingTimeInterval(-600),
            coverageEnd: now.addingTimeInterval(-1),
            pendingRequestIDs: []
        )
        let historySource = AvailableHistory(snapshot: snapshot)
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: historySource
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            createdAt: now
        )

        await #expect(throws: SafetyRejection.insufficientHistory) {
            try await deliveryGuard.deliver(request)
        }
        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }
    @Test
    func acceptsExactHistoryCoverageButStillRequiresContext() async throws {
        let pump = RecordingPump()
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = FixedClock(date: now)
        let limits = try SafetyLimits(
            maxBolus: try InsulinUnits(units: 2.0),
            maxIOB: try InsulinUnits(units: 3.0),
            historyLookback: 600.0
        )
        let snapshot = try DoseHistorySnapshot(
            events: [],
            coverageStart: now.addingTimeInterval(-600),
            coverageEnd: now,
            pendingRequestIDs: []
        )
        let historySource = AvailableHistory(snapshot: snapshot)
        let deliveryGuard = InsulinDeliveryGuard(
            limits: limits,
            pump: pump,
            clock: clock,
            historySource: historySource
        )
        let request = try DoseRequest(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            createdAt: now
        )

        await #expect(throws: SafetyRejection.invalidContext) {
            try await deliveryGuard.deliver(request)
        }
        let attempts = await pump.deliveryCallCount
        #expect(attempts == 0)
    }
}
