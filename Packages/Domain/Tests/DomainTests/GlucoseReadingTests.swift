import Foundation
import Testing

@testable import Domain

@Suite("GlucoseReading")
struct GlucoseReadingTests {
    @Test
    func storesMeasurementAndTimestamp() {
        let glucose = Glucose(mgdL: 120)
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

        let reading = GlucoseReading(
            glucose: glucose,
            timestamp: timestamp
        )

        #expect(reading.glucose == glucose)
        #expect(reading.timestamp == timestamp)
    }

    @Test
    func compareMeasurementAndTimestamp() {
        let glucose = Glucose(mgdL: 120)
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

        let first = GlucoseReading(
            glucose: glucose,
            timestamp: timestamp
        )

        let identical = GlucoseReading(
            glucose: glucose,
            timestamp: timestamp
        )

        let differentGlucose = GlucoseReading(
            glucose: Glucose(mgdL: 100),
            timestamp: timestamp
        )

        let differentTimestamp = GlucoseReading(
            glucose: glucose,
            timestamp: timestamp.addingTimeInterval(60)
        )

        #expect(first == identical)
        #expect(first != differentGlucose)
        #expect(first != differentTimestamp)

    }
}
