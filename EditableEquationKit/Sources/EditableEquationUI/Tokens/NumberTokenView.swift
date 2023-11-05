//
//  NumberTokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

struct NumberTokenView: TokenView {
    var number: NumberToken
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    @EnvironmentObject var manager: EquationManager

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
            .background {
                if let numberEditor = manager.numberEditor {
                    BackgroundHighlightView(numberEditor: numberEditor, treeLocation: treeLocation)
                }
            }
    }

    struct BackgroundHighlightView: View {
        @ObservedObject var numberEditor: NumberEditor
        var treeLocation: TokenTreeLocation

        var body: some View {
            if numberEditor.editingNumber == treeLocation {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .opacity(0.7)
            }
        }
    }

    var editTapSection: some View {
        Color.red.opacity(0.0001)
            .onTapGesture {
                manager.numberEditor?.editingNumber = treeLocation
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
