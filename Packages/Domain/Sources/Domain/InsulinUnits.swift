public struct InsulinUnits: Sendable, Comparable, Hashable {

    public let units: Double

    public init(units: Double) throws(DomainQuantityError) {
        guard units.isFinite, units >= 0 else {
            throw DomainQuantityError.invalidInsulinUnits(units)
        }
        self.units = units
    }
    public static func < (lhs: InsulinUnits, rhs: InsulinUnits) -> Bool {
        lhs.units < rhs.units
    }

}
