//
//  LinearGroupView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI

struct LinearGroupView: View {
    var linearGroup: LinearGroup
    var treeLocation: TokenTreeLocation

    var body: some View {
        HStack(spacing: 0) {
            if linearGroup.hasBrackets {
                Text("(")
                    .overlay {
                        SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading))
                    }
            }
            if linearGroup.contents.isEmpty {
                Text("_")
                    .overlay {
                        SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .within))
                    }
            } else {
                ForEach(linearGroup.contents) { content in
                    TokenView(token: content, treeLocation: self.treeLocation.adding(pathComponent: content.id))
                }
            }
            if linearGroup.hasBrackets {
                Text(")")
                    .overlay {
                        SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing))
                    }
            }
        }
    }
}
