//
//  NavigationSectionView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 5/11/23.
//

import SwiftUI
import EditableEquationKit
import EditableEquationCore

struct NavigationSectionView: View {
    @ObservedObject var manager: EquationManager
    @ObservedObject var numberEditor: NumberEditor

    init(manager: EquationManager, numberEditor: NumberEditor) {
        self.manager = manager
        self.numberEditor = numberEditor
    }

    var body: some View {
        HStack {
            arrowView
            numberEditView
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

    @ViewBuilder var numberEditView: some View {
        if let editingLocation = numberEditor.editingNumber,
           let numberToken = manager.tokenAt(location: editingLocation) as? NumberToken {
            RoundedRectangle(
                cornerRadius: 16
            )
            .fill(.ultraThickMaterial)
            .overlay {
                HStack {
                    NumberEditView(manager: manager, path: editingLocation, token: numberToken)
                    Button {
                        numberEditor.editingNumber = nil
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 10)
            }
            .padding(.vertical, -5)
            .font(.system(.title))
        } else {
            RoundedRectangle(
                cornerRadius: 16
            )
            .fill(.ultraThickMaterial)
            .opacity(0.7)
            .padding(.vertical, -5)
        }
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
