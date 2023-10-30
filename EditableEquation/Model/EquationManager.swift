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

    /// The token to the left of the location, if it exists
    private func tokenLeading(location: TokenTreeLocation) -> EquationToken? {
        guard let lastItemID = location.pathComponents.last else { return nil }

        let parentItem: EquationToken

        if location.pathComponents.count == 1 {
            parentItem = .linearGroup(root)
        } else {
            guard let parentOfLocation = tokenAt(location: location.removingLastPathComponent()) else { return nil }
            parentItem = parentOfLocation
        }

        switch parentItem {
        case .linearGroup(let linearGroup):
            guard let locationIndex = linearGroup.contents.firstIndex(where: { $0.id == lastItemID }),
                  locationIndex > 0
            else { return nil }

            return linearGroup.contents[locationIndex-1]
        default: return nil
        }
    }

    /// The token to the right of the location, if it exists
    private func tokenTrailing(location: TokenTreeLocation) -> EquationToken? {
        guard let lastItemID = location.pathComponents.last else { return nil }

        let parentItem: EquationToken

        if location.pathComponents.count == 1 {
            parentItem = .linearGroup(root)
        } else {
            guard let parentOfLocation = tokenAt(location: location.removingLastPathComponent()) else { return nil }
            parentItem = parentOfLocation
        }

        switch parentItem {
        case .linearGroup(let linearGroup):
            guard let locationIndex = linearGroup.contents.firstIndex(where: { $0.id == lastItemID }),
                  locationIndex < linearGroup.contents.count-1
            else { return nil }

            return linearGroup.contents[locationIndex+1]
        default: return nil
        }
    }

    /// The new insertion point if moved to the left
    private func insertionLeft(of insertionPoint: InsertionPoint) -> InsertionPoint {
        var mutableInsertionPoint = insertionPoint

        // there are some situations where you only need to change the insertion location
        switch insertionPoint.insertionLocation {
        case .trailing, .within:
            mutableInsertionPoint.insertionLocation = .leading
            return mutableInsertionPoint
        default: break
        }

        // if a token exists to the left of the insertion point, use it
        if let leadingToken = tokenLeading(location: insertionPoint.treeLocation) {
            let newTreeLocation = mutableInsertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: leadingToken.id)
            mutableInsertionPoint.treeLocation = newTreeLocation
            return mutableInsertionPoint
        }

        // else, the location is the parent's leading
        let newTreeLocation = mutableInsertionPoint.treeLocation.removingLastPathComponent()
        mutableInsertionPoint.treeLocation = newTreeLocation
        return mutableInsertionPoint
    }

    /// The new insertion point if moved to the right
    private func insertionRight(of insertionPoint: InsertionPoint) -> InsertionPoint {
        var mutableInsertionPoint = insertionPoint

        // there are some situations where you only need to change the insertion location
        switch insertionPoint.insertionLocation {
        case .leading, .within:
            mutableInsertionPoint.insertionLocation = .trailing
            return mutableInsertionPoint
        default: break
        }

        // if a token exists to the right of the insertion point, use it
        if let trailingToken = tokenTrailing(location: insertionPoint.treeLocation) {
            let newTreeLocation = mutableInsertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: trailingToken.id)
            mutableInsertionPoint.treeLocation = newTreeLocation
            return mutableInsertionPoint
        }

        // else, the location is the parent's trailing
        let newTreeLocation = mutableInsertionPoint.treeLocation.removingLastPathComponent()
        mutableInsertionPoint.treeLocation = newTreeLocation
        return mutableInsertionPoint
    }
}
