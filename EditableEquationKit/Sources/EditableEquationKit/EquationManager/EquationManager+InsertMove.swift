//
//  EquationManager+InsertMove.swift
//
//
//  Created by Kai Quan Tay on 6/11/23.
//

import Foundation
import EditableEquationCore

extension EquationManager {
    /// Gets the token at a location relative to root, if it exists
    public func tokenAt(location: TokenTreeLocation) -> (any EquationToken)? {
        var currentToken: any EquationToken = root

        // If theres no last item, the path components is empty and it refers to root
        guard let lastItem = location.pathComponents.last else { return root }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(with: lastItem)
    }

    /// The token to the left of the location, if it exists
    internal func tokenLeading(location: TokenTreeLocation) -> (any EquationToken)? {
        var currentToken: any EquationToken = root

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(leftOf: lastItem)
    }

    /// The token to the right of the location, if it exists
    internal func tokenTrailing(location: TokenTreeLocation) -> (any EquationToken)? {
        var currentToken: any EquationToken = root

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(rightOf: lastItem)
    }

    /// The new insertion point if moved to the left
    internal func insertionLeft(of insertionPoint: InsertionPoint) -> InsertionPoint {
        insertionInDirection(insertionPoint: insertionPoint, goingLeft: true)
    }

    /// The new insertion point if moved to the right
    internal func insertionRight(of insertionPoint: InsertionPoint) -> InsertionPoint {
        insertionInDirection(insertionPoint: insertionPoint, goingLeft: false)
    }
}
