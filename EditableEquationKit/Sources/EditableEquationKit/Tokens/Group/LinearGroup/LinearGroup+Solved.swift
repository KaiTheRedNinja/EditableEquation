//
//  LinearGroup+Solved.swift
//  
//
//  Created by Kai Quan Tay on 4/11/23.
//

import Foundation
import EditableEquationCore
import Rationals

extension LinearGroup: ValueEquationToken {
    public func solved() throws -> Fraction<Int> {
        // solve each of the values
        enum SolveStep {
            case operation(LinearOperationToken)
            case value(Fraction<Int>)

            var description: String {
                switch self {
                case .operation(let linearOperationToken):
                    "\(linearOperationToken.operation)"
                case .value(let solution):
                    "\(solution)"
                }
            }
        }

        var solvedWithOperations: [SolveStep] = []
        for item in contents {
            if let operation = item as? LinearOperationToken {
                solvedWithOperations.append(.operation(operation))
            } else if let value = item as? any ValueEquationToken {
                let solution = try value.solved()
                solvedWithOperations.append(.value(solution))
            }
        }

        // put a "+" before "-" (but only if its the first operation, so "---3" becomes "+---3")
        var previousWasMinus: Bool = false
        for index in (0..<solvedWithOperations.count).reversed() {
            switch solvedWithOperations[index] {
            case .operation(let operation):
                previousWasMinus = operation.operation == .minus
                continue
            default: break
            }

            // if previous was minus and it isn't a linear operation, insert a plus
            if previousWasMinus {
                solvedWithOperations.insert(.operation(LinearOperationToken(operation: .plus)), at: index+1)
            }

            previousWasMinus = false
        }

        // get rid of minus signs, integrate them into the solved values
        for index in (0..<solvedWithOperations.count).reversed() {
            switch solvedWithOperations[index] {
            case .operation(let operation):
                guard operation.operation == .minus else { continue }

                let lastValue = solvedWithOperations[index+1]

                switch lastValue {
                case .value(let value):
                    let newValue: SolveStep = .value(value * -1)
                    solvedWithOperations[index] = newValue
                    solvedWithOperations.remove(at: index+1)
                default: fatalError("Internal inconsistency")
                }
            default: break
            }
        }

        // flip the equation, because we solve it last element to first element
        // which would violate the order of operations if we didn't
        solvedWithOperations.reverse()

        // go through the array, solve all the multiplication and division
        for index in (0..<solvedWithOperations.count).reversed() {
            switch solvedWithOperations[index] {
            case .operation(let operation):
                let result: Fraction<Int>
                switch operation.operation {
                case .times, .divide:
                    // multiply the terms to the left and right of the symbol
                    switch solvedWithOperations[index-1] {
                    case .value(let leftValue):
                        switch solvedWithOperations[index+1] {
                        case .value(let rightValue):
                            if operation.operation == .times {
                                result = rightValue * leftValue
                            } else {
                                result = rightValue / leftValue // the "right" value is actually left, since we flipped it
                            }
                        default: fatalError("Internal inconsistency")
                        }
                    default: fatalError("Internal inconsistency")
                    }
                default: continue
                }

                // assign the new value to the item on the left,
                // then delete the operation and the item on the right
                solvedWithOperations[index-1] = .value(result)
                solvedWithOperations.remove(at: index+1)
                solvedWithOperations.remove(at: index)
            default: break
            }
        }

        // do the same thing with addition and subtraction
        for index in (0..<solvedWithOperations.count).reversed() {
            switch solvedWithOperations[index] {
            case .operation(let operation):
                let result: Fraction<Int>
                switch operation.operation {
                case .plus, .minus:
                    // multiply the terms to the left and right of the symbol
                    switch solvedWithOperations[index-1] {
                    case .value(let leftValue):
                        switch solvedWithOperations[index+1] {
                        case .value(let rightValue):
                            if operation.operation == .plus {
                                result = rightValue + leftValue
                            } else {
                                result = rightValue - leftValue
                            }
                        default: fatalError("Internal inconsistency")
                        }
                    default: fatalError("Internal inconsistency")
                    }
                default: continue
                }

                // assign the new value to the item on the left,
                // then delete the operation and the item on the right
                solvedWithOperations[index-1] = .value(result)
                solvedWithOperations.remove(at: index+1)
                solvedWithOperations.remove(at: index)
            default: break
            }
        }

        guard solvedWithOperations.count == 1, let solvedValue = solvedWithOperations.first
        else { fatalError("Calculation failed") }

        switch solvedValue {
        case .operation:
            fatalError("Left with an operation: this is impossible")
        case .value(let solution):
            return solution
        }
    }
}
