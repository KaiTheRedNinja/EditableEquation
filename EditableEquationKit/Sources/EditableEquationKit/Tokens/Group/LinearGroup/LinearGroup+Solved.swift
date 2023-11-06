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
    private enum SolveStep {
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

    public func solved() throws -> Fraction<Int> {
        // solve each of the values
        var solvedWithOperations: [SolveStep] = try solveValues()

        // fix double negatives
        solvedWithOperations = try normaliseNegativeSolveSteps(solvedWithOperations)

        // solve it using order of operations
        solvedWithOperations = try solveArithmetic(solvedWithOperations)

        guard solvedWithOperations.count == 1, let solvedValue = solvedWithOperations.first
        else { fatalError("Calculation failed") }

        switch solvedValue {
        case .operation:
            fatalError("Left with an operation: this is impossible")
        case .value(let solution):
            return solution
        }
    }

    private func solveValues() throws -> [SolveStep] {
        var solvedWithOperations: [SolveStep] = []
        for item in contents {
            if let operation = item as? LinearOperationToken {
                solvedWithOperations.append(.operation(operation))
            } else if let value = item as? any ValueEquationToken {
                let solution = try value.solved()
                solvedWithOperations.append(.value(solution))
            }
        }
        return solvedWithOperations
    }

    private func normaliseNegativeSolveSteps(_ initial: [SolveStep]) throws -> [SolveStep] {
        var solvedWithOperations = initial

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

        return solvedWithOperations
    }

    private func solveArithmetic(_ initial: [SolveStep]) throws -> [SolveStep] {
        // flip the equation, because we solve it last element to first element
        // which would violate the order of operations if we didn't
        var solvedWithOperations: [SolveStep] = initial.reversed()

        // go through the array, solve all the multiplication and division
        solvedWithOperations = solveArithmeticOperation(
            solvedWithOperations,
            operations: [
                .times: { $0*$1 },
                .divide: { $0/$1 }
            ]
        )

        solvedWithOperations = solveArithmeticOperation(
            solvedWithOperations,
            operations: [
                .plus: { $0+$1 },
                .minus: { $0-$1 }
            ]
        )

        return solvedWithOperations
    }

    private func solveArithmeticOperation(
        _ initial: [SolveStep],
        operations: [LinearOperationToken.LinearOperation: (Fraction<Int>, Fraction<Int>) -> Fraction<Int>]
    ) -> [SolveStep] {
        var solvedWithOperations = initial
        for index in (0..<solvedWithOperations.count).reversed() {
            switch solvedWithOperations[index] {
            case .operation(let operation):
                guard operations.keys.contains(operation.operation) else { continue }

                var result: Fraction<Int>?
                // multiply the terms to the left and right of the symbol
                switch solvedWithOperations[index-1] {
                case .value(let leftValue):
                    switch solvedWithOperations[index+1] {
                    case .value(let rightValue):
                        for (potentialOperation, operationToPerform) in operations
                            where operation.operation == potentialOperation {
                            // the "right" value is actually left, since we flipped it
                            result = operationToPerform(rightValue, leftValue)
                            break
                        }
                    default: fatalError("Internal inconsistency")
                    }
                default: fatalError("Internal inconsistency")
                }

                guard let result else { continue }

                // assign the new value to the item on the left,
                // then delete the operation and the item on the right
                solvedWithOperations[index-1] = .value(result)
                solvedWithOperations.remove(at: index+1)
                solvedWithOperations.remove(at: index)
            default: break
            }
        }
        return solvedWithOperations
    }
}
