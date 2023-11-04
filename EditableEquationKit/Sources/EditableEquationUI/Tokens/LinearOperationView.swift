//
//  LinearOperationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

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
                guard linearOperation.operation == .divide,
                      let parent = manager.tokenAt(location: treeLocation.removingLastChild()) as? any GroupEquationToken,
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

                let newDivisionGroup = DivisionGroup(numerator: [elementBefore], denominator: [elementAfter])

                withAnimation {
                    manager.replace(token: newDivisionGroup, at: treeLocation)
                    manager.remove(at: treeLocation.removingLastChild().appending(child: elementBefore.id))
                    manager.remove(at: treeLocation.removingLastChild().appending(child: elementAfter.id))
                }
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
