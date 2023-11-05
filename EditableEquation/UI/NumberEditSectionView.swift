//
//  NumberEditSectionView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 5/11/23.
//

import SwiftUI
import EditableEquationKit
import EditableEquationCore

struct NumberEditSectionView: View {
    @ObservedObject var manager: EquationManager
    @ObservedObject var numberEditor: NumberEditor

    init(manager: EquationManager, numberEditor: NumberEditor) {
        self.manager = manager
        self.numberEditor = numberEditor
    }

    var editingLocation: TokenTreeLocation? { numberEditor.editingNumber }
    var numberToken: NumberToken? {
        guard let editingLocation else { return nil }
        return manager.tokenAt(location: editingLocation) as? NumberToken
    }

    var body: some View {
        HStack {
            if numberToken == nil {
                deleteView
                    .opacity(0)
                Spacer()
            }

            arrowView

            if let numberToken {
                numberEditView(for: numberToken)
            } else {
                Spacer()
            }

            deleteView
        }
        .frame(height: 75)
    }

    var arrowView: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    manager.moveLeft()
                }
            } label: {
                Image(systemName: "arrowtriangle.left.fill").frame(height: 70)
            }
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    manager.moveRight()
                }
            } label: {
                Image(systemName: "arrowtriangle.right.fill").frame(height: 70)
            }
        }
        .font(.system(.largeTitle))
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }

    func numberEditView(for numberToken: NumberToken) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThickMaterial)
            .overlay {
                HStack {
                    Spacer()
                    Text(String(numberToken.digit))
                        .lineLimit(1)
                    Button {
                        numberEditor.editingNumber = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 10)
            }
            .padding(.vertical, -5)
            .font(.system(.title))
    }

    var deleteView: some View {
        Button {
            withAnimation {
                manager.backspace()
            }
        } label: {
            Image(systemName: "delete.left").frame(height: 75)
        }
        .font(.system(.title))
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }
}
