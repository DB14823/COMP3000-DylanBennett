import Foundation

public struct DoseRequest: Sendable, Equatable {
    public let id: UUID
    public let amount: InsulinUnits
    public let createdAt: Date

    public init(id: UUID, amount: InsulinUnits, createdAt: Date)
        throws(DoseRequestError)
    {
        guard amount.units > 0 else {
            throw DoseRequestError.zeroAmount
        }
        self.id = id
        self.amount = amount
        self.createdAt = createdAt
    }
}
