//
//  EquationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct EquationView: View {
    @ObservedObject var equationManager: EquationManager

    init(root: LinearGroup) {
        self.equationManager = .init(root: root)
    }

    init(manager: EquationManager) {
        self.equationManager = manager
    }

    var body: some View {
        TokenView(
            token: .linearGroup(equationManager.root),
            treeLocation: .init(pathComponents: [])
        )
        .environmentObject(equationManager)
    }
}
