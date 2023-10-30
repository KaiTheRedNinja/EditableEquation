//
//  EquationManager.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 29/10/23.
//

import Foundation

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
        guard let destination = tokenAt(location: insertionPoint.treeLocation) else {
            print("Destination invalid")
            return
        }
        print("Inserting \(token) at \(destination)'s \(insertionPoint.insertionLocation)")
        root.insert(token: token, at: insertionPoint)
    }

    func move(from initialLocation: TokenTreeLocation, to insertionPoint: InsertionPoint) {
        print("Moving \(initialLocation) to \(insertionPoint)")
    }

    func remove(at location: TokenTreeLocation) {

    }
}

extension EquationManager {
    private func tokenAt(location: TokenTreeLocation) -> EquationToken? {
        var currentToken: EquationToken = .linearGroup(root)

        for component in location.pathComponents {
            switch currentToken {
            case .linearGroup(let linearGroup):
                if let newToken = linearGroup.contents.first(where: { $0.id == component }) {
                    currentToken = newToken
                } else {
                    return nil
                }
            default: return nil
            }
        }

        return currentToken
    }
}
