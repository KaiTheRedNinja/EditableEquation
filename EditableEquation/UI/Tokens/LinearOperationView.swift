//
//  LinearOperationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI

struct LinearOperationView: View {
    var linearOperation: LinearOperationToken
    var treeLocation: TokenTreeLocation

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        Text(operationText)
            .padding(.horizontal, 3)
            .overlay {
                HStack(spacing: 0) {
                    SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading))
                    transformTapSection
                    SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing))
                }
            }
    }

    var transformTapSection: some View {
        Color.red.opacity(0.0001).onTapGesture {
            withAnimation {
                manager.replace(
                    token: .linearOperation(
                        .init(
                            id: linearOperation.id,
                            operation: linearOperation.operation.next()
                        )
                    ),
                    at: treeLocation
                )
            }
        }
    }

    var operationText: String {
        switch linearOperation.operation {
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
