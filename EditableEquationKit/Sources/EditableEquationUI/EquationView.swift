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
    @ObservedObject var numberEditor: NumberEditor

    @Namespace var namespace

    public init(root: LinearGroup, numberEditor: NumberEditor? = nil) {
        self.equationManager = .init(root: root)
        self.numberEditor = numberEditor ?? .init()
    }

    public init(manager: EquationManager, numberEditor: NumberEditor? = nil) {
        self.equationManager = manager
        self.numberEditor = numberEditor ?? .init()
    }

    public var body: some View {
        GeneralTokenView(
            token: equationManager.root,
            treeLocation: .init(pathComponents: []),
            namespace: namespace
        )
        .environmentObject(equationManager)
        .environmentObject(numberEditor)
    }
}
