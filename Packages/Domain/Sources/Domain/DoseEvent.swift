import Foundation

public struct DoseEvent: Sendable, Equatable {
    public let id: UUID
    public let amount: InsulinUnits
    public let timestamp: Date

    public init(id: UUID, amount: InsulinUnits, timestamp: Date) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
    }
}
