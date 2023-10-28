//
//  EquationView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

class EquationManager: ObservableObject {
    @Published var root: LinearGroup

    init(root: LinearGroup) {
        self.root = root
    }

    func insert(token: EquationToken, at: InsertionPoint) {

    }

    func remove(at: TokenTreeLocation) {

    }
}

struct EquationView: View {
    @StateObject var equationManager: EquationManager

    init(root: LinearGroup) {
        self._equationManager = .init(wrappedValue: .init(root: root))
    }

    var body: some View {
        TokenView(token: .linearGroup(equationManager.root))
            .environmentObject(equationManager)
    }
}
