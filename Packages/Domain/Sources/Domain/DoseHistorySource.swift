import Foundation

public enum DoseHistoryAvailability: Sendable, Equatable {
    case available(DoseHistorySnapshot)
    case unavailable
}

public protocol DoseHistorySource: Sendable {
    func history(
        from start: Date,
        through end: Date
    ) async -> DoseHistoryAvailability
}
