import Testing
@testable import Domain

@Suite("InsulinUnits")
struct InsulinUnitsTests {
    @Test(arguments: [0.0, 0.05, 1.25, 10.0])
    func storesValidQuantity(_ value: Double) throws {
        let quantity = try InsulinUnits(units: value)

        #expect(quantity.units == value)
    }

    @Test(arguments: [-0.01, -1.0, .infinity, -.infinity, .nan])
    func rejectsInvalidQuantity(_ value: Double) {
        #expect(throws: DomainQuantityError.self) {
            try InsulinUnits(units: value)
        }
    }

    @Test
    func comparesQuantities() throws {
        let smaller = try InsulinUnits(units: 1.0)
        let larger = try InsulinUnits(units: 2.0)
        let sameValue = try InsulinUnits(units: 1.0)

        #expect(smaller == sameValue)
        #expect(smaller < larger)
        #expect(!(smaller < smaller))
        #expect(!(larger < smaller))
    }
}
