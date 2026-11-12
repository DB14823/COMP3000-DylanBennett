import Testing

@testable import Domain

@Suite("Carbs")
struct CarbTests {
    @Test(arguments: [0.0, 0.05, 1.25, 10.0])
    func storesValidQuantity(_ value: Double) throws {
        let quantity = try Carbs(grams: value)

        #expect(quantity.grams == value)
    }

    @Test(arguments: [-0.01, -1.0, .infinity, -.infinity, .nan])
    func rejectsInvalidQuantity(_ value: Double) {
        #expect(throws: DomainQuantityError.self) {
            try Carbs(grams: value)
        }
    }

    @Test
    func comparesQuantities() throws {
        let smaller = try Carbs(grams: 1.0)
        let larger = try Carbs(grams: 2.0)
        let sameValue = try Carbs(grams: 1.0)
        #expect(smaller == sameValue)
        #expect(smaller < larger)
        #expect(!(smaller < smaller))
        #expect(!(larger < smaller))
    }
}
