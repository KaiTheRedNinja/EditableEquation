//
//  LinearOperationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit
import Rationals

struct LinearOperationView: TokenView {
    var linearOperation: LinearOperationToken
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        Text(operationText(op: linearOperation.operation))
            .padding(.horizontal, 3)
            .overlay {
                HStack(spacing: 0) {
                    SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading), namespace: namespace)
                    transformTapSection
                    SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing), namespace: namespace)
                }
            }
            .contextMenu {
                ForEach(LinearOperationToken.LinearOperation.allCases, id: \.hashValue) { op in
                    Button(operationText(op: op)) {
                        withAnimation {
                            manager.replace(
                                token: LinearOperationToken(
                                    id: linearOperation.id,
                                    operation: op
                                ),
                                at: treeLocation
                            )
                        }
                    }
                }
            }
    }

    var transformTapSection: some View {
        Color.red.opacity(0.0001)
            .onTapGesture {
                convertSelf()
            }
    }

    func operationText(op: LinearOperationToken.LinearOperation) -> String {
        switch op {
        case .plus:
            "+"
        case .minus:
            "-"
        case .times:
            "×"
        case .divide:
            "÷"
        }
    }

    func convertSelf() {
        if linearOperation.operation == .divide {
            convertToFraction()
        } else if linearOperation.operation == .times {
            shuffleFactors()
        }
    }

    /// Converts this operation and  the items to the left and right into a fraction
    func convertToFraction() {
        guard let parent = manager.tokenAt(location: treeLocation.removingLastChild()) as? any GroupEquationToken,
              var elementBefore = parent.child(leftOf: linearOperation.id),
              var elementAfter = parent.child(rightOf: linearOperation.id)
        else { return }

        if var leadingGroup = elementBefore as? LinearGroup {
            leadingGroup.hasBrackets = false
            elementBefore = leadingGroup
        }

        if var trailingGroup = elementAfter as? LinearGroup {
            trailingGroup.hasBrackets = false
            elementAfter = trailingGroup
        }

        let newDivisionGroup = DivisionGroup(
            id: linearOperation.id,
            numerator: [elementBefore],
            denominator: [elementAfter]
        )

        withAnimation {
            manager.replace(token: newDivisionGroup, at: treeLocation)
            manager.remove(at: treeLocation.removingLastChild().appending(child: elementBefore.id))
            manager.remove(at: treeLocation.removingLastChild().appending(child: elementAfter.id))
        }
    }

    /// Shuffles the terms on the left and right to cycle through the factors of the product
    func shuffleFactors() {
        guard let parent = manager.tokenAt(location: treeLocation.removingLastChild()) as? any GroupEquationToken,
              var elementBefore = parent.child(leftOf: linearOperation.id) as? NumberToken,
              let leadingValue = try? elementBefore.solved(),
              leadingValue%1 == 0,
              var elementAfter = parent.child(rightOf: linearOperation.id) as? NumberToken,
              let trailingValue = try? elementAfter.solved(),
              trailingValue%1 == 0
        else { return }

        let sum: Fraction<Int> = leadingValue * trailingValue
        guard sum > 0, sum%1 == 0 else { return }
        let sumInt = sum.numerator/sum.denominator

        // get the factors of the sum
        let factors = findFactors(of: sumInt)

        // find the factor larger than `leadingValue`. If there isn't any, use the smallest value
        guard let indexOfLeadingValue = factors.firstIndex(of: leadingValue.numerator/leadingValue.denominator)
        else { return }

        if indexOfLeadingValue+1 == factors.count,
            let firstFactor = factors.first {
            elementBefore.digit = firstFactor
        } else {
            elementBefore.digit = factors[indexOfLeadingValue+1]
        }

        elementAfter.digit = sumInt/elementBefore.digit

        guard elementBefore.digit * elementAfter.digit == sumInt else { return }

        // replace them
        withAnimation {
            manager.replace(token: elementBefore, at: treeLocation.removingLastChild().appending(child: elementBefore.id))
            manager.replace(token: elementAfter, at: treeLocation.removingLastChild().appending(child: elementAfter.id))
        }
    }
}

private func findFactors(of n: Int) -> [Int] {
    precondition(n > 0, "n must be positive")
    let sqrtn = Int(Double(n).squareRoot())
    var factors: [Int] = []
    factors.reserveCapacity(2 * sqrtn)
    for i in 1...sqrtn {
        if n % i == 0 {
            factors.append(i)
        }
    }
    var j = factors.count - 1
    if factors[j] * factors[j] == n {
        j -= 1
    }
    while j >= 0 {
        factors.append(n / factors[j])
        j -= 1
    }
    return factors
}

fileprivate extension LinearOperationToken.LinearOperation {
    func next() -> LinearOperationToken.LinearOperation {
        switch self {
        case .plus: .divide
        case .minus: .plus
        case .times: .minus
        case .divide: .times
        }
    }
}
