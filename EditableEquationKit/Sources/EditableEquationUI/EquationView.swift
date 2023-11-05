//
//  EquationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI
import EditableEquationKit

/// A view that manages an Equation
public struct EquationView: View {
    @ObservedObject var equationManager: EquationManager

    @Namespace var namespace

    public init(root: LinearGroup, numberEditor: NumberEditor? = nil) {
        self.equationManager = .init(root: root)
        equationManager.numberEditor = numberEditor
    }

    public init(manager: EquationManager) {
        self.equationManager = manager
    }

    public var body: some View {
        GeneralTokenView(
            token: equationManager.root,
            treeLocation: .init(pathComponents: []),
            namespace: namespace
        )
        .environmentObject(equationManager)
    }
}
