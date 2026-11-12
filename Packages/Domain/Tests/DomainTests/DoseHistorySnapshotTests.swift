import Foundation
import Testing

@testable import Domain

@Suite("DoseHistorySnapshot")
struct DoseHistorySnapshotTests {

    @Test
    func preservesCoverageForEmptyHistory() throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let snapshot = try DoseHistorySnapshot(
            events: [],
            coverageStart: start,
            coverageEnd: end,
            pendingRequestIDs: []
        )

        #expect(snapshot.events.isEmpty)
        #expect(snapshot.coverageStart == start)
        #expect(snapshot.coverageEnd == end)
        #expect(snapshot.pendingRequestIDs.isEmpty)
    }

    @Test
    func rejectsReversedCoverage() throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(60)

        #expect(throws: DoseHistoryError.invalidCoverage) {
            try DoseHistorySnapshot(
                events: [],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )
        }
    }

    @Test(arguments: [Double.infinity, -Double.infinity, Double.nan])
    func rejectsNonFiniteCoverageStart(_ value: Double) {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = Date(timeIntervalSinceReferenceDate: value)

        #expect(throws: DoseHistoryError.invalidCoverage) {
            try DoseHistorySnapshot(
                events: [],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )

        }
    }

    @Test(arguments: [Double.infinity, -Double.infinity, Double.nan])
    func rejectsNonFiniteCoverageEnd(_ value: Double) {
        let end = Date(timeIntervalSinceReferenceDate: value)
        let start = Date(timeIntervalSince1970: 1_700_000_000)

        #expect(throws: DoseHistoryError.invalidCoverage) {
            try DoseHistorySnapshot(
                events: [],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )
        }
    }

    @Test
    func rejectsEventBeforeCoverage() throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let event = DoseEvent(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            timestamp: start.addingTimeInterval(-1)
        )

        #expect(throws: DoseHistoryError.eventOutsideCoverage) {
            try DoseHistorySnapshot(
                events: [event],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )
        }
    }

    @Test
    func rejectsEventAfterCoverage() throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let event = DoseEvent(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            timestamp: end.addingTimeInterval(1)
        )
        #expect(throws: DoseHistoryError.eventOutsideCoverage) {
            try DoseHistorySnapshot(
                events: [event],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )
        }
    }

    @Test(arguments: [Double.infinity, -Double.infinity, Double.nan])
    func rejectsNonFiniteEventTimestamp(_ value: Double) throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let event = DoseEvent(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            timestamp: Date(timeIntervalSinceReferenceDate: value)
        )
        #expect(throws: DoseHistoryError.eventOutsideCoverage) {
            try DoseHistorySnapshot(
                events: [event],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )
        }
    }

    @Test(arguments: [0.0, 300.0, 600.0])
    func acceptsEventWithinCoverage(_ offset: Double) throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let event = DoseEvent(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            timestamp: start.addingTimeInterval(offset)
        )
        let snapshot = try DoseHistorySnapshot(
            events: [event],
            coverageStart: start,
            coverageEnd: end,
            pendingRequestIDs: []
        )
        #expect(snapshot.events == [event])
    }

    @Test
    func rejectsDuplicateEventIDs() throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let event = DoseEvent(
            id: UUID(),
            amount: try InsulinUnits(units: 1.0),
            timestamp: start.addingTimeInterval(300)
        )
        #expect(throws: DoseHistoryError.duplicateEventID) {
            try DoseHistorySnapshot(
                events: [event, event],
                coverageStart: start,
                coverageEnd: end,
                pendingRequestIDs: []
            )
        }
    }
    @Test
    func acceptsDistinctEventsWithMatchingDetails() throws {
        let end = Date(timeIntervalSince1970: 1_700_000_000)
        let start = end.addingTimeInterval(-600)
        let firstID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000001"
        )!
        let secondID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000002"
        )!
        let first = DoseEvent(
            id: firstID,
            amount: try InsulinUnits(units: 1.0),
            timestamp: start.addingTimeInterval(300)
            )
        let second = DoseEvent(
            id: secondID,
            amount: try InsulinUnits(units: 1.0),
            timestamp: start.addingTimeInterval(300)
            )
        let snapshot = try DoseHistorySnapshot(
            events: [first, second],
            coverageStart: start,
            coverageEnd: end,
            pendingRequestIDs: []
        )
        #expect(snapshot.events == [first, second])
    }
}
