import Foundation

public struct CarbEntry: Sendable, Equatable {
    public let id: UUID
    public let amount: Carbs
    public let timestamp: Date

    public init(id: UUID, amount: Carbs, timestamp: Date) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
    }
}
