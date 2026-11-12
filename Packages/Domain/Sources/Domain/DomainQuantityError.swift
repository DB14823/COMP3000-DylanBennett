public enum DomainQuantityError: Error, Sendable {
    case invalidInsulinUnits(Double)
    case invalidCarbs(Double)
}
