import Foundation

public enum DeliveryResult: Sendable, Equatable {
    case confirmed(
        requestID: UUID,
        deliveredAmount: InsulinUnits,
        completedAt: Date
    )
    case uncertain(
        requestID: UUID,
        recordedAt: Date
    )
}
