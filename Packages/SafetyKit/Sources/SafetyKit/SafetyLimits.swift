import Domain

public enum SafetyLimitsError: Error, Sendable, Equatable {
    case invalidHistoryLookback
}
public struct SafetyLimits: Sendable, Equatable {
    public let maxBolus: InsulinUnits
    public let maxIOB: InsulinUnits
    public let historyLookback: Double
    public init(
        maxBolus: InsulinUnits,
        maxIOB: InsulinUnits,
        historyLookback: Double
    ) throws(SafetyLimitsError) {
        if !historyLookback.isFinite {
            throw .invalidHistoryLookback
        }
        if !(historyLookback > 0) {
            throw .invalidHistoryLookback
        }
        self.maxIOB = maxIOB
        self.maxBolus = maxBolus
        self.historyLookback = historyLookback
    }
}
