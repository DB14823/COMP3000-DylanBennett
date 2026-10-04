public struct BolusFraction: Sendable, Hashable {
    public static let validRange: ClosedRange<Double> = 0.1...1.0

    public let value: Double

    public init(_ value: Double) throws(TherapySettingsError) {
        guard Self.validRange.contains(value) else {
            throw .fractionOutOfRange(value)
        }
        self.value = value
    }
}
