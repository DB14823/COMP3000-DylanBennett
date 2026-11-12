public struct Carbs: Sendable, Comparable, Hashable {

    public let grams: Double

    public init(grams: Double) throws(DomainQuantityError) {
        guard grams.isFinite, grams >= 0 else {
            throw DomainQuantityError.invalidCarbs(grams)
        }
        self.grams = grams
    }
    public static func < (lhs: Carbs, rhs: Carbs) -> Bool {
        lhs.grams < rhs.grams
    }

}
