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

    var body: some View {
        Text(operationText)
            .padding(.horizontal, 3)
            .overlay {
                SimpleLeadingTrailingDropOverlay(treeLocation: treeLocation)
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
