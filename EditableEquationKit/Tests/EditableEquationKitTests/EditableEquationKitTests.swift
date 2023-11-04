import XCTest
@testable import EditableEquationKit
@testable import EditableEquationCore

final class EditableEquationKitTests: XCTestCase {
    func testFractions() throws {
        let frac = FractionValue(numerator: 1, denominator: 2)
        let frac2 = FractionValue(numerator: 3, denominator: 4)
        let result = FractionValue(numerator: 3, denominator: 8)
        XCTAssertEqual(frac*frac2, result)
    }
}
