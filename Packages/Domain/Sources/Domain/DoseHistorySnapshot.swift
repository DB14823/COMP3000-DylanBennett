import Foundation

public enum DoseHistoryError: Error, Sendable, Equatable {
    case invalidCoverage
    case eventOutsideCoverage
    case duplicateEventID
}
public struct DoseHistorySnapshot: Sendable, Equatable {
    public let events: [DoseEvent]
    public let coverageStart: Date
    public let coverageEnd: Date
    public let pendingRequestIDs: Set<UUID>

    public init(
        events: [DoseEvent],
        coverageStart: Date,
        coverageEnd: Date,
        pendingRequestIDs: Set<UUID>
    ) throws(DoseHistoryError) {
        if !(coverageEnd.timeIntervalSinceReferenceDate.isFinite) {
            throw .invalidCoverage
        }
        if !(coverageStart.timeIntervalSinceReferenceDate.isFinite) {
            throw .invalidCoverage
        }
        if !(coverageStart <= coverageEnd) {
            throw .invalidCoverage
        }
        var seenIDs = Set<UUID>()
        for event in events {
            if !(event.timestamp.timeIntervalSinceReferenceDate.isFinite) {
                throw DoseHistoryError.eventOutsideCoverage
            }
            if event.timestamp < coverageStart {
                throw DoseHistoryError.eventOutsideCoverage
            }
            if event.timestamp > coverageEnd {
                throw DoseHistoryError.eventOutsideCoverage
            }
            if seenIDs.contains(event.id) {
                throw DoseHistoryError.duplicateEventID
            }
            seenIDs.insert(event.id)
        }
        self.coverageEnd = coverageEnd
        self.coverageStart = coverageStart
        self.events = events
        self.pendingRequestIDs = pendingRequestIDs
    }
}
