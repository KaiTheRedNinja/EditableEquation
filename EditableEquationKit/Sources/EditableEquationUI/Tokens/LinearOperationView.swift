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
    var token: LinearOperationToken
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    @EnvironmentObject var manager: EquationManager

    init(token: LinearOperationToken, treeLocation: EditableEquationCore.TokenTreeLocation, namespace: Namespace.ID) {
        self.token = token
        self.treeLocation = treeLocation
        self.namespace = namespace
    }

    var body: some View {
        Text(operationText(operation: token.operation))
            .padding(.horizontal, 3)
            .overlay {
                HStack(spacing: 0) {
                    SimpleDropOverlay(
                        insertionPoint: .init(
                            treeLocation: treeLocation,
                            insertionLocation: .leading
                        ),
                        namespace: namespace
                    )
                    transformTapSection
                    SimpleDropOverlay(
                        insertionPoint: .init(
                            treeLocation: treeLocation,
                            insertionLocation: .trailing
                        ),
                        namespace: namespace
                    )
                }
            }
            .contextMenu {
                ForEach(LinearOperationToken.LinearOperation.allCases, id: \.hashValue) { operation in
                    Button(operationText(operation: operation)) {
                        withAnimation {
                            manager.replace(
                                token: LinearOperationToken(
                                    id: token.id,
                                    operation: operation
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

    func operationText(operation: LinearOperationToken.LinearOperation) -> String {
        switch operation {
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
        if token.operation == .divide {
            convertToFraction()
        } else if token.operation == .times {
            shuffleFactors()
        }
    }

    /// Converts this operation and  the items to the left and right into a fraction
    func convertToFraction() {
        guard let parent = manager.tokenAt(location: treeLocation.removingLastChild()) as? any GroupEquationToken,
              var elementBefore = parent.child(leftOf: token.id),
              var elementAfter = parent.child(rightOf: token.id)
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
            id: token.id,
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
              var elementBefore = parent.child(leftOf: token.id) as? NumberToken,
              let leadingValue = try? elementBefore.solved(),
              leadingValue%1 == 0,
              var elementAfter = parent.child(rightOf: token.id) as? NumberToken,
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
            manager.replace(
                token: elementBefore,
                at: treeLocation.removingLastChild().appending(child: elementBefore.id)
            )
            manager.replace(
                token: elementAfter,
                at: treeLocation.removingLastChild().appending(child: elementAfter.id)
            )
        }
    }
}

private func findFactors(of number: Int) -> [Int] {
    precondition(number > 0, "n must be positive")
    let sqrtn = Int(Double(number).squareRoot())
    var factors: [Int] = []
    factors.reserveCapacity(2 * sqrtn)
    for index in 1...sqrtn where number % index == 0 {
        factors.append(index)
    }
    var lastIndex = factors.count - 1
    if factors[lastIndex] * factors[lastIndex] == number {
        lastIndex -= 1
    }
    while lastIndex >= 0 {
        factors.append(number / factors[lastIndex])
        lastIndex -= 1
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
