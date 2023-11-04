import XCTest
@testable import EditableEquationKit
@testable import EditableEquationCore

final class LinearGroupTests: XCTestCase {
    let uuids = (0..<20).map({ _ in UUID() })

    // TO TEST:
    //
    // Solving
    // BODMAS
    // Double negatives
    // Implied multiplication

    func testLinearGroupSimpleOptimisation() throws {
        // optimising single linear group out
        let initialGroup = LinearGroup(
            id: uuids[0],
            contents: [
                LinearGroup(
                    id: uuids[1],
                    contents: [
                        NumberToken(id: uuids[2], digit: 4),
                        LinearOperationToken(id: uuids[3], operation: .divide),
                        NumberToken(id: uuids[4], digit: 5)
                    ],
                    hasBrackets: false
                ),
                LinearOperationToken(id: uuids[5], operation: .plus),
                NumberToken(id: uuids[6], digit: 8)
            ],
            hasBrackets: false
        )

        let finalGroup = LinearGroup(
            id: uuids[0],
            contents: [
                NumberToken(id: uuids[2], digit: 4),
                LinearOperationToken(id: uuids[3], operation: .divide),
                NumberToken(id: uuids[4], digit: 5),
                LinearOperationToken(id: uuids[5], operation: .plus),
                NumberToken(id: uuids[6], digit: 8)
            ],
            hasBrackets: false
        )

        let optimised = initialGroup.optimised()
        XCTAssertTrue(optimised is LinearGroup)
        let optimisedGroup = optimised as! LinearGroup
        XCTAssertEqual("\(optimisedGroup)", "\(finalGroup)")
    }

    func testLinearGroupAdvancedOptimisation() throws {
        // optimising multiple layers deep, making sure not to optimise out brackets
        let initialGroup = LinearGroup(
            id: uuids[0],
            contents: [
                LinearGroup(
                    id: uuids[1],
                    contents: [
                        NumberToken(id: uuids[2], digit: 4),
                        LinearOperationToken(id: uuids[3], operation: .divide),
                        LinearGroup(
                            id: uuids[4],
                            contents: [
                                NumberToken(id: uuids[5], digit: 5)
                            ],
                            hasBrackets: false
                        ),
                    ],
                    hasBrackets: false
                ),
                LinearOperationToken(id: uuids[6], operation: .plus),
                LinearGroup(
                    id: uuids[7],
                    contents: [
                        NumberToken(id: uuids[8], digit: 9)
                    ],
                    hasBrackets: true
                ),
            ],
            hasBrackets: false
        )

        let finalGroup = LinearGroup(
            id: uuids[0],
            contents: [
                NumberToken(id: uuids[2], digit: 4),
                LinearOperationToken(id: uuids[3], operation: .divide),
                NumberToken(id: uuids[5], digit: 5),
                LinearOperationToken(id: uuids[6], operation: .plus),
                LinearGroup(
                    id: uuids[7],
                    contents: [
                        NumberToken(id: uuids[8], digit: 9)
                    ],
                    hasBrackets: true
                )
            ],
            hasBrackets: false
        )

        let optimised = initialGroup.optimised()
        XCTAssertTrue(optimised is LinearGroup)
        let optimisedGroup = optimised as! LinearGroup
        XCTAssertEqual("\(optimisedGroup)", "\(finalGroup)")
    }
}
