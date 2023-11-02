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
        root = (root.inserting(token: token, at: insertionPoint) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
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
        root = (root.removing(at: location) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
        updateErrors()
    }

    /// Replaces the contents of a location with another token
    public func replace(token: any EquationToken, at location: TokenTreeLocation) {
        root = (root.replacing(token: token, at: location) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
        updateErrors()
    }

    /// Moves a token from an initial location to an insertion point
    public func move(from initialLocation: TokenTreeLocation, to insertionPoint: InsertionPoint) {
        guard let token = tokenAt(location: initialLocation) else { return }
        root = (root.removing(at: initialLocation) as? LinearGroup) ?? root
        root = (root.inserting(token: token, at: insertionPoint) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
        updateErrors()
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
