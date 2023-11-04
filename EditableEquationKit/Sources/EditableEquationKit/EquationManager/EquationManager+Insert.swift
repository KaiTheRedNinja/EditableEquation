//
//  EquationManager+Insert.swift
//  
//
//  Created by Kai Quan Tay on 2/11/23.
//

import Foundation
import EditableEquationCore

extension EquationManager {
    /// A function that chooses either `insert` or `moved` based on the data provided
    public func manage(data: Data, droppedAt insertionPoint: InsertionPoint) {
        if let source = String(data: data, encoding: .utf8),
           let token = try? EquationTokenCoding.decodeSingle(source: source) {
            insert(token: token, at: insertionPoint)
        }
        if let location = try? JSONDecoder().decode(TokenTreeLocation.self, from: data) {
            move(from: location, to: insertionPoint)
        }
    }

    /// Insert a token at an insertion point
    public func insert(token: any EquationToken, at insertionPoint: InsertionPoint) {
        guard let insertionReferenceID = insertionPoint.treeLocation.pathComponents.last else {
            print("Invalid insertion point")
            return
        }

        // get the parents of the token
        var parents: [any EquationToken] = [root]
        let parentLocation: TokenTreeLocation
        if insertionPoint.insertionLocation == .within {
            parentLocation = insertionPoint.treeLocation
        } else {
            parentLocation = insertionPoint.treeLocation.removingLastChild()
        }
        for tokenID in parentLocation.pathComponents {
            guard let nextItem = parents.last?.groupRepresentation?.child(with: tokenID) else {
                print("Tried to insert at a nonexistant location")
                return
            }
            parents.append(nextItem)
        }

        // insert the token
        let lastIndex = parents.count - 1

        guard let newParent = parents[lastIndex].groupRepresentation?.inserting(
            token: token,
            at: insertionPoint.insertionLocation,
            relativeToID: insertionPoint.insertionLocation == .within ? nil : insertionReferenceID
        ) else {
            print("Could not insert the token")
            return
        }

        parents[lastIndex] = newParent

        // work the way back up the tree, updating it along the way
        for index in (0..<lastIndex).reversed() {
            let prevTokenIndex = index+1
            guard let newToken = parents[index].groupRepresentation?.replacing(
                originalTokenID: parentLocation.pathComponents[prevTokenIndex-1], // we use -1 here because pathComponents doesn't contain root
                with: parents[prevTokenIndex]
            ) else {
                print("Could not rebuild tree")
                return
            }

            parents[index] = newToken
        }

        guard let newRoot = parents.first?.groupRepresentation?.optimised() as? LinearGroup else {
            print("Could not get root from rebuilt tree")
            return
        }

        self.root = newRoot
        updateErrors()
    }

    /// Deletes the item to the left of the insertion point
    public func backspace() {
        guard let insertionPoint else { return }
        switch insertionPoint.insertionLocation {
        case .trailing, .within:
            // if its trailing/within, just delete the tree location
            // TODO: Fix this with division groups, removing `within` should delete the parent token
            remove(at: insertionPoint.treeLocation)
        default:
            // else, go left and delete that
            moveLeft()
            guard let insertionPoint = self.insertionPoint else { return }
            remove(at: insertionPoint.treeLocation)
        }
        updateErrors()
    }

    /// Removes the item at a certain location
    public func remove(at location: TokenTreeLocation) {
        guard let tokenToRemove: UUID = location.pathComponents.last else {
            print("No token to remove")
            return
        }

        // get the parents of the token
        var parents: [any EquationToken] = [root]
        let parentLocation = location.removingLastChild()
        for tokenID in parentLocation.pathComponents {
            guard let nextItem = parents.last?.groupRepresentation?.child(with: tokenID) else {
                print("Tried to remove at a nonexistant location")
                return
            }
            parents.append(nextItem)
        }

        // remove the token, and at the same time build the tree back up
        for index in (0..<parents.count).reversed() {

            // if this is the last item, try and remove the token
            if index == parents.count-1 {
                if let newToken = parents[index].groupRepresentation?.removing(childID: tokenToRemove) {
                    parents[index] = newToken
                } else {
                    // if the removal failed, chop of the array past this item
                    parents = Array(parents[0..<index])
                }

                continue
            }

            // if this is not the last item, start rebuilding the tree
            let prevTokenIndex = index+1
            guard let newToken = parents[index].groupRepresentation?.replacing(
                originalTokenID: parentLocation.pathComponents[prevTokenIndex-1], // we use -1 here because pathComponents doesn't contain root
                with: parents[prevTokenIndex]
            ) else {
                print("Could not rebuild tree")
                return
            }

            parents[index] = newToken
        }

        guard let newRoot = parents.first?.groupRepresentation?.optimised() as? LinearGroup else {
            print("Could not get root from rebuilt tree")
            return
        }

        self.root = newRoot
        updateErrors()
    }

    /// Replaces the contents of a location with another token
    public func replace(token: any EquationToken, at location: TokenTreeLocation) {
        guard let replacementID = location.pathComponents.last else {
            print("Invalid insertion point")
            return
        }

        // get the parents of the token
        var parents: [any EquationToken] = [root]
        let parentLocation = location.removingLastChild()
        for tokenID in parentLocation.pathComponents {
            guard let nextItem = parents.last?.groupRepresentation?.child(with: tokenID) else {
                print("Tried to replace at a nonexistant location")
                return
            }
            parents.append(nextItem)
        }

        // replace the token
        let lastIndex = parents.count - 1

        guard let newParent = parents[lastIndex].groupRepresentation?.replacing(
            originalTokenID: replacementID,
            with: token
        ) else {
            print("Could not insert the token")
            return
        }

        parents[lastIndex] = newParent

        // work the way back up the tree, updating it along the way
        for index in (0..<lastIndex).reversed() {
            let prevTokenIndex = index+1
            guard let newToken = parents[index].groupRepresentation?.replacing(
                originalTokenID: parentLocation.pathComponents[prevTokenIndex-1], // we use -1 here because pathComponents doesn't contain root
                with: parents[prevTokenIndex]
            ) else {
                print("Could not rebuild tree")
                return
            }

            parents[index] = newToken
        }

        guard let newRoot = parents.first?.groupRepresentation?.optimised() as? LinearGroup else {
            print("Could not get root from rebuilt tree")
            return
        }

        self.root = newRoot
        updateErrors()
    }

    /// Moves a token from an initial location to an insertion point
    public func move(from initialLocation: TokenTreeLocation, to insertionPoint: InsertionPoint) {
        guard let token = tokenAt(location: initialLocation) else { return }
        remove(at: initialLocation)
        insert(token: token, at: insertionPoint)
        // no need to optimise or update errors, `remove` and `insert` do that for us
    }

    /// Moves the cursor to the left of the current position
    public func moveLeft() {
        guard let insertionPoint else { return }
        var newInsertion = insertionLeft(of: insertionPoint)
        while true { // NOTE: Check this code to ensure it can never cause infinite recursion
            // Make sure the token exists. If it doesnt, something has gone very wrong.
            guard let token = tokenAt(location: newInsertion.treeLocation) else { return }
            if token.groupRepresentation?.canInsert(at: insertionPoint.insertionLocation) ?? true {
                break
            } else {
                newInsertion = insertionLeft(of: newInsertion)
            }
        }
        self.insertionPoint = newInsertion
    }

    /// Moves the cursor to the right of the current position
    public func moveRight() {
        guard let insertionPoint else { return }
        var newInsertion = insertionRight(of: insertionPoint)
        while true { // NOTE: Check this code to ensure it can never cause infinite recursion
            // Make sure the token exists. If it doesnt, something has gone very wrong.
            guard let token = tokenAt(location: newInsertion.treeLocation) else { return }
            if token.groupRepresentation?.canInsert(at: insertionPoint.insertionLocation) ?? true {
                break
            } else {
                newInsertion = insertionRight(of: newInsertion)
            }
        }
        self.insertionPoint = newInsertion
    }
}
