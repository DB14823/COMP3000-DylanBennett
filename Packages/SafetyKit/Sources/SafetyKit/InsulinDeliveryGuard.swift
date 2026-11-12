import Domain
import PumpPort

public actor InsulinDeliveryGuard {
    private let limits: SafetyLimits
    private let pump: any PumpDriver
    private let clock: any LoopClock
    private let historySource: any DoseHistorySource
    public init(
        limits: SafetyLimits,
        pump: any PumpDriver,
        clock: any LoopClock,
        historySource: any DoseHistorySource
    ) {
        self.limits = limits
        self.pump = pump
        self.clock = clock
        self.historySource = historySource
    }
    public func deliver(
        _ request: DoseRequest
    ) async throws(SafetyRejection) -> DeliveryResult {
        if request.amount > limits.maxBolus {
            throw .bolusLimitExceeded
        }
        let now = clock.now()
        if request.createdAt > now {
            throw .invalidRequestTime
        }
        let historyStart = now.addingTimeInterval(-limits.historyLookback)
        let history = await historySource.history(
            from: historyStart,
            through: now
        )
        switch history {
        case .unavailable:
            throw .invalidContext
        case .available(let snapshot):
            if !snapshot.pendingRequestIDs.isEmpty {
                throw .deliveryPending
            }
            if snapshot.coverageStart > historyStart {
                throw .insufficientHistory
            }
            if snapshot.coverageEnd < now {
                throw .insufficientHistory
            }
            throw .invalidContext
        }

    }
}
