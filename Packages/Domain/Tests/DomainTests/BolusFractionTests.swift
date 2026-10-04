import Testing
@testable import Domain

@Suite("BolusFraction")
struct BolusFractionTests {
    @Test(arguments: [0.1, 0.5, 0.7, 1.0])
    func acceptsValuesInRange(_ v: Double) throws {
        #expect(try BolusFraction(v).value == v)
    }

    @Test(arguments: [0.0, 0.0999, 1.0001, -0.5, 2.0, .infinity, -.infinity])
    func rejectsValuesOutOfRange(_ v: Double) {
        #expect(throws: TherapySettingsError.fractionOutOfRange(v)) {
            try BolusFraction(v)
        }
    }

    @Test func rejectsNaN() {
        // NaN != NaN, so an equality-based expectation can't match it.
        // #expect(throws:) returns the thrown error, so inspect the case instead.
        let error = #expect(throws: TherapySettingsError.self) {
            try BolusFraction(.nan)
        }
        guard case .fractionOutOfRange(let v)? = error else {
            Issue.record("Expected .fractionOutOfRange, got \(String(describing: error))")
            return
        }
        #expect(v.isNaN)
    }
}
