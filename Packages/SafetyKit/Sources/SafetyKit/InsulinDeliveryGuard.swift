import Domain
import PumpPort

public actor InsulinDeliveryGuard {
    private let limits: SafetyLimits
    private let pump: any PumpDriver
    private let clock: any LoopClock
    public init(
        limits: SafetyLimits,
        pump: any PumpDriver,
        clock: any LoopClock
    ) {
        self.limits = limits
        self.pump = pump
        self.clock = clock
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

        throw .invalidContext

    }
}
