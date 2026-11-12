import Domain
import PumpPort

public actor InsulinDeliveryGuard {
    private let limits: SafetyLimits
    private let pump: any PumpDriver
    public init(limits: SafetyLimits, pump: any PumpDriver) {
        self.limits = limits
        self.pump = pump
    }
    public func deliver(
        _ request: DoseRequest
    ) async throws(SafetyRejection) -> DeliveryResult {
        if request.amount > limits.maxBolus {
            throw .bolusLimitExceeded
        } else {
            throw .invalidContext
        }
    }
}
