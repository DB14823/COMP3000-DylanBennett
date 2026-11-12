import Domain

public struct SafetyLimits: Sendable, Equatable {
    public let maxBolus: InsulinUnits
    public let maxIOB: InsulinUnits
    public init(maxBolus: InsulinUnits, maxIOB: InsulinUnits) {
        self.maxIOB = maxIOB
        self.maxBolus = maxBolus
    }
}
