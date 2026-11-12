import Foundation

public struct GlucoseReading: Sendable, Equatable {
    public let glucose: Glucose
    public let timestamp: Date

    public init(glucose: Glucose, timestamp: Date) {
        self.glucose = glucose
        self.timestamp = timestamp
    }
}
