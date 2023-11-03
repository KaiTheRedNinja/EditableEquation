//
//  EquationManager+InsertPrivate.swift
//
//
//  Created by Kai Quan Tay on 2/11/23.
//

import Foundation
import EditableEquationCore

extension EquationManager {
    internal func tokenAt(location: TokenTreeLocation) -> (any EquationToken)? {
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
        // If the tree location is the root's first item
        if insertionPoint.treeLocation.pathComponents.count == 1,
           insertionPoint.treeLocation.pathComponents.first == root.firstChild()?.id {
            // if its the trailing, then switch to leading
            if insertionPoint.insertionLocation == .trailing {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .leading
                )
            }

            // if its the leading, then wrap around to the other end
            if insertionPoint.insertionLocation == .leading {
                return .init(
                    treeLocation: .init(pathComponents: [root.lastChild()!.id]),
                    insertionLocation: .trailing
                )
            }
        }

        // If its within, it just changes to a leading
        if insertionPoint.insertionLocation == .within {
            return .init(
                treeLocation: insertionPoint.treeLocation,
                insertionLocation: .leading
            )
        }

        // If its the trailing of a group token, try and enter it.
        if insertionPoint.insertionLocation == .trailing,
           let token = tokenAt(location: insertionPoint.treeLocation),
           let tokenGroup = token.groupRepresentation {
            if let lastChild = tokenGroup.lastChild() {
                return .init(
                    treeLocation: insertionPoint.treeLocation.appending(child: lastChild.id),
                    insertionLocation: .trailing
                )
            } else {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .within
                )
            }
        }

        // Get the parent of the item
        guard let item = insertionPoint.treeLocation.pathComponents.last,
              let parent = tokenAt(location: insertionPoint.treeLocation.removingLastChild()),
              let parentGroup = parent.groupRepresentation else {
            print("Somehow this token has no parent")
            return insertionPoint
        }

        // Get the previous child
        if let prevChild = parentGroup.child(leftOf: item) {
            // If the current insertion point is a trailng, go to the trailing of the previous child
            if insertionPoint.insertionLocation == .trailing {
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: prevChild.id),
                    insertionLocation: .trailing
                )
            }

            // If the current insertion point is a leading, try and enter the child
            if insertionPoint.insertionLocation == .leading,
               let childGroup = prevChild.groupRepresentation {
                if let lastChild = childGroup.lastChild() {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: prevChild.id).appending(child: lastChild.id),
                        insertionLocation: .trailing
                    )
                } else {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: prevChild.id),
                        insertionLocation: .within
                    )
                }
            } else {
                // If it can't be entered, go to the leading of the child
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: prevChild.id),
                    insertionLocation: .leading
                )
            }
        } else {
            // If its the first item in a group and a trailing, go to leading
            if insertionPoint.insertionLocation == .trailing {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .leading
                )
            } else { // if its a leading, break out to the group's leading
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild(),
                    insertionLocation: .leading
                )
            }
        }
    }

    /// The new insertion point if moved to the right
    internal func insertionRight(of insertionPoint: InsertionPoint) -> InsertionPoint {
        // If the tree location is the root's last item
        if insertionPoint.treeLocation.pathComponents.count == 1,
           insertionPoint.treeLocation.pathComponents.first == root.lastChild()?.id {
            // if its the leading, then switch to trailing
            if insertionPoint.insertionLocation == .leading {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .trailing
                )
            }

            // if its the trailing, then wrap around to the other end
            if insertionPoint.insertionLocation == .trailing {
                return .init(
                    treeLocation: .init(pathComponents: [root.firstChild()!.id]),
                    insertionLocation: .leading
                )
            }
        }

        // If its within, it just changes to a trailing
        if insertionPoint.insertionLocation == .within {
            return .init(
                treeLocation: insertionPoint.treeLocation,
                insertionLocation: .trailing
            )
        }

        // If its the leading of a group token, try and enter it.
        if insertionPoint.insertionLocation == .leading,
           let token = tokenAt(location: insertionPoint.treeLocation),
           let tokenGroup = token.groupRepresentation {
            if let firstChild = tokenGroup.firstChild() {
                return .init(
                    treeLocation: insertionPoint.treeLocation.appending(child: firstChild.id),
                    insertionLocation: .leading
                )
            } else {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .within
                )
            }
        }

        // Get the parent of the item
        guard let item = insertionPoint.treeLocation.pathComponents.last,
              let parent = tokenAt(location: insertionPoint.treeLocation.removingLastChild()),
              let parentGroup = parent.groupRepresentation else {
            print("Somehow this token has no parent")
            return insertionPoint
        }

        // Get the next child
        if let nextChild = parentGroup.child(rightOf: item) {
            // If the current insertion point is a leading, go to the leading of the next child
            if insertionPoint.insertionLocation == .leading {
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: nextChild.id),
                    insertionLocation: .leading
                )
            }

            // If the current insertion point is a trailing, try and enter the child
            if insertionPoint.insertionLocation == .trailing,
               let childGroup = nextChild.groupRepresentation {
                if let firstChild = childGroup.firstChild() {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: nextChild.id).appending(child: firstChild.id),
                        insertionLocation: .leading
                    )
                } else {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: nextChild.id),
                        insertionLocation: .within
                    )
                }
            } else {
                // If it can't be entered, go to the trailing of the child
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: nextChild.id),
                    insertionLocation: .trailing
                )
            }
        } else {
            // If its the last item in a group and a leading, go to trailing
            if insertionPoint.insertionLocation == .leading {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .trailing
                )
            } else { // if its a trailing, break out to the group's trailing
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild(),
                    insertionLocation: .trailing
                )
            }
        }
    }
}
