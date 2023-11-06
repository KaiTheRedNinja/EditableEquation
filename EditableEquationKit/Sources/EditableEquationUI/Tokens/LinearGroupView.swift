//
//  LinearGroupView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

struct LinearGroupView: TokenView {
    var linearGroup: LinearGroup
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            if linearGroup.hasBrackets {
                Text("(")
                    .overlay {
                        SimpleDropOverlay(
                            insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading),
                            namespace: namespace
                        )
                    }
            }
            if linearGroup.contents.isEmpty {
                Text("_")
                    .overlay {
                        SimpleDropOverlay(
                            insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .within),
                            namespace: namespace
                        )
                    }
            } else {
                ForEach(0..<linearGroup.contents.count, id: \.self) { index in
                    let content = linearGroup.contents[index]
                    GeneralTokenView(
                        token: content,
                        treeLocation: self.treeLocation.appending(child: content.id),
                        namespace: namespace
                    )
                }
            }
            if linearGroup.hasBrackets {
                Text(")")
                    .overlay {
                        SimpleDropOverlay(
                            insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing),
                            namespace: namespace
                        )
                    }
            }
        }
    }
}
