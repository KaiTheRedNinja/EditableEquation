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

    /// A function that chooses either `insert` or `moved` based on the data provided
    func manage(data: Data, droppedAt insertionPoint: InsertionPoint) {
        if let token = try? JSONDecoder().decode(EquationToken.self, from: data) {
            insert(token: token, at: insertionPoint)
        }
        if let location = try? JSONDecoder().decode(TokenTreeLocation.self, from: data) {
            move(from: location, to: insertionPoint)
        }
    }

    func insert(token: EquationToken, at insertionPoint: InsertionPoint) {
        print("Inserting \(token) at \(insertionPoint)")
    }

    func move(from initialLocation: TokenTreeLocation, to insertionPoint: InsertionPoint) {
        print("Moving \(initialLocation) to \(insertionPoint)")
    }

    func remove(at location: TokenTreeLocation) {

    }
}

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
