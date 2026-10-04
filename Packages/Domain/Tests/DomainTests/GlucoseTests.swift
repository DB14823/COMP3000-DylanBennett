import Testing
@testable import Domain

@Suite("Glucose")
struct GlucoseTests {
    @Test func storesCanonicalMgdL() {
        #expect(Glucose(mgdL: 120).mgdL == 120)
    }

    @Test func convertsMgdLToMmolL() {
        // 180 mg/dL / 18.0182 = 9.98990...
        #expect(abs(Glucose(mgdL: 180).mmolL - 9.9899) < 0.0001)
    }

    @Test func mmolLInitialiserStoresMgdL() {
        // 5.5 mmol/L * 18.0182 = 99.1001
        #expect(abs(Glucose(mmolL: 5.5).mgdL - 99.1001) < 0.0001)
    }

    @Test(arguments: [2.2, 3.9, 5.5, 10.0, 22.2, 33.3])
    func roundTripsThroughMmolL(_ mmol: Double) {
        #expect(abs(Glucose(mmolL: mmol).mmolL - mmol) < 1e-9)
    }

    @Test func comparesByValue() {
        #expect(Glucose(mmolL: 3.9) < Glucose(mmolL: 4.0))
        #expect(Glucose(mgdL: 100) == Glucose(mgdL: 100))
    }
}
