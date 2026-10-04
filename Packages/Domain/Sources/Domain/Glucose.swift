public struct Glucose: Sendable, Hashable, Comparable {
    
    public static let mgdLPerMmolL: Double = 18.0182
    
    public let mgdL: Double
    
    public var mmolL: Double {
        mgdL / Self.mgdLPerMmolL
    }
    
    public init(mgdL: Double){
        self.mgdL = mgdL
    }
    public init (mmolL: Double) {
        self.init(mgdL: mmolL * Self.mgdLPerMmolL)
    }
    
    public static func < (lhs: Glucose, rhs: Glucose) -> Bool {
        lhs.mgdL < rhs.mgdL
    }
}
