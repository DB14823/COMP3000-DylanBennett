import Domain
import Testing

@testable import SafetyKit

@Suite("SafetyLimits")
struct SafetyLimitsTests {
    @Test(arguments: [0.0, -1.0, Double.infinity, -Double.infinity, Double.nan])
    func rejectsInvalidHistoryLookback(_ value: Double) throws {
        let maxIOB = try InsulinUnits(units: 3.0)
        let maxBolus = try InsulinUnits(units: 2.0)
        #expect(throws: SafetyLimitsError.invalidHistoryLookback) {
            try SafetyLimits(
                maxBolus: maxBolus,
                maxIOB: maxIOB,
                historyLookback: value
            )
        }
    }
}
