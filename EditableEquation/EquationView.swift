//
//  EquationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct EquationView: View {
    @StateObject var equationManager: EquationManager

    init(root: LinearGroup) {
        self._equationManager = .init(wrappedValue: .init(root: root))
    }

    var body: some View {
        TokenView(
            token: .linearGroup(equationManager.root),
            treeLocation: .init(pathComponents: [])
        )
        .environmentObject(equationManager)
    }
}
