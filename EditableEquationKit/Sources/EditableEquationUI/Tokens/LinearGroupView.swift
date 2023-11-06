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
    var token: LinearGroup
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    init(token: LinearGroup, treeLocation: EditableEquationCore.TokenTreeLocation, namespace: Namespace.ID) {
        self.token = token
        self.treeLocation = treeLocation
        self.namespace = namespace
    }

    var body: some View {
        HStack(spacing: 0) {
            if token.hasBrackets {
                Text("(")
                    .overlay {
                        SimpleDropOverlay(
                            insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading),
                            namespace: namespace
                        )
                    }
            }
            if token.contents.isEmpty {
                Text("_")
                    .overlay {
                        SimpleDropOverlay(
                            insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .within),
                            namespace: namespace
                        )
                    }
            } else {
                ForEach(0..<token.contents.count, id: \.self) { index in
                    let content = token.contents[index]
                    GeneralTokenView(
                        token: content,
                        treeLocation: self.treeLocation.appending(child: content.id),
                        namespace: namespace
                    )
                }
            }
            if token.hasBrackets {
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
