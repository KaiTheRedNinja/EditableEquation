//
//  EquationManager.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 29/10/23.
//

import Foundation

class EquationManager: ObservableObject {
    @Published var root: LinearGroup
    @Published var insertionPoint: InsertionPoint?

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
        root = root.inserting(token: token, at: insertionPoint)

        root = root.optimised()
    }

    func move(from initialLocation: TokenTreeLocation, to insertionPoint: InsertionPoint) {
        print("Moving \(initialLocation) to \(insertionPoint)")
        root = root.optimised()
    }

    func remove(at location: TokenTreeLocation) {
        root = root.optimised()
    }

    func moveLeft() {
        guard let insertionPoint else { return }
        self.insertionPoint = insertionLeft(of: insertionPoint)
    }

    func moveRight() {
        guard let insertionPoint else { return }
        self.insertionPoint = insertionRight(of: insertionPoint)
    }
}

extension EquationManager {
    private func tokenAt(location: TokenTreeLocation) -> EquationToken? {
        var currentToken: EquationToken = .linearGroup(root)

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(with: lastItem)
    }

    /// The token to the left of the location, if it exists
    private func tokenLeading(location: TokenTreeLocation) -> EquationToken? {
        var currentToken: EquationToken = .linearGroup(root)

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(leftOf: lastItem)
    }

    /// The token to the right of the location, if it exists
    private func tokenTrailing(location: TokenTreeLocation) -> EquationToken? {
        var currentToken: EquationToken = .linearGroup(root)

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(rightOf: lastItem)
    }

    /// The new insertion point if moved to the left
    private func insertionLeft(of insertionPoint: InsertionPoint) -> InsertionPoint {
        return insertionPoint
    }

    /// The new insertion point if moved to the right
    private func insertionRight(of insertionPoint: InsertionPoint) -> InsertionPoint {
        return insertionPoint
    }
}
