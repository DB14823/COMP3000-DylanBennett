import Foundation
import Domain

public enum PumpStatus: Sendable, Equatable {
    case ready
    case unavailable
}

public protocol PumpDriver: Sendable {
    func status() async -> PumpStatus

    func deliver(_ request: DoseRequest) async -> DeliveryResult

    func reconcile(requestID: UUID) async -> DeliveryResult
}
