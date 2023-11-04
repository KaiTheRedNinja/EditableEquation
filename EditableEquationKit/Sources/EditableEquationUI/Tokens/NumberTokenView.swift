//
//  NumberTokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

public class NumberEditor: ObservableObject {
    @Published public var editingNumber: TokenTreeLocation?

    public init(editingNumber: TokenTreeLocation? = nil) {
        self.editingNumber = editingNumber
    }
}

struct NumberTokenView: TokenView {
    var number: NumberToken
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    @EnvironmentObject var editor: NumberEditor

    var body: some View {
        Text(String(number.digit))
            .padding(.horizontal, 3)
            .overlay {
                HStack(spacing: 0) {
                    SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading), namespace: namespace)
                    editTapSection
                    SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing), namespace: namespace)
                }
            }
    }

    var editTapSection: some View {
        Color.red.opacity(0.0001)
            .onTapGesture {
                editor.editingNumber = treeLocation
            }
    }

    var formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}
