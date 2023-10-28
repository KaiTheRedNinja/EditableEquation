//
//  TokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct TokenView: View {
    var token: EquationToken
    var treeLocation: TokenTreeLocation

    var body: some View {
        switch token {
        case .number(let numberToken):
            NumberTokenView(number: numberToken, treeLocation: treeLocation)
        case .linearOperation(let linearOperationToken):
            LinearOperationView(linearOperation: linearOperationToken, treeLocation: treeLocation)
        case .linearGroup(let linearGroup):
            LinearGroupView(linearGroup: linearGroup, treeLocation: treeLocation)
        }
    }
}

struct SimpleLeadingTrailingDropOverlay: View {
    var treeLocation: TokenTreeLocation

    @Binding var dropHighlight: InsertionPoint.InsertionLocation?

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        HStack(spacing: 0) {
            if dropHighlight == .leading {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 3)
            }
            Color.blue.opacity(0.0001)
                .dropDestination(for: Data.self) { items, location in
                    for item in items {
                        manager.manage(data: item, droppedAt: .init(treeLocation: treeLocation, insertionLocation: .leading))
                    }
                    return true
                } isTargeted: { isTargeted in
                    print("Is targeted: \(isTargeted)")
                    dropHighlight = isTargeted ? .leading : nil
                }

            Color.red.opacity(0.0001)
                .dropDestination(for: Data.self) { items, location in
                    for item in items {
                        manager.manage(data: item, droppedAt: .init(treeLocation: treeLocation, insertionLocation: .trailing))
                    }
                    return true
                } isTargeted: { isTargeted in
                    print("Is targeted: \(isTargeted)")
                    dropHighlight = isTargeted ? .trailing : nil
                }
            if dropHighlight == .trailing {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 3)
            }
        }
    }
}

struct NumberTokenView: View {
    var number: NumberToken
    var treeLocation: TokenTreeLocation

    @State var dropHighlight: InsertionPoint.InsertionLocation?

    var body: some View {
        Text("\(number.digit)")
            .padding(.horizontal, 3)
            .overlay {
                SimpleLeadingTrailingDropOverlay(treeLocation: treeLocation, dropHighlight: $dropHighlight)
            }
    }
}

struct LinearOperationView: View {
    var linearOperation: LinearOperationToken
    var treeLocation: TokenTreeLocation

    @State var dropHighlight: InsertionPoint.InsertionLocation?

    var body: some View {
        Text(operationText)
            .padding(.horizontal, 3)
            .overlay {
                SimpleLeadingTrailingDropOverlay(treeLocation: treeLocation, dropHighlight: $dropHighlight)
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

struct LinearGroupView: View {
    var linearGroup: LinearGroup
    var treeLocation: TokenTreeLocation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(linearGroup.contents) { content in
                TokenView(token: content, treeLocation: self.treeLocation.adding(pathComponent: content.id))
            }
        }
    }
}
