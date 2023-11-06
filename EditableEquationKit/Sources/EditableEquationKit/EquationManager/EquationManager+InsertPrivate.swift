//
//  EquationManager+InsertPrivate.swift
//
//
//  Created by Kai Quan Tay on 2/11/23.
//

import Foundation
import EditableEquationCore

extension EquationManager {
    internal func insertionInDirection(insertionPoint: InsertionPoint, goingLeft: Bool) -> InsertionPoint {
        // If the tree location is the root's first/last item
        if let newPoint = insertionAtEdges(insertionPoint: insertionPoint, goingLeft: goingLeft) {
            return newPoint
        }

        // If its within, it just changes to a leading/trailing
        if let newPoint = insertionWithin(insertionPoint: insertionPoint, goingLeft: goingLeft) {
            return newPoint
        }

        // If its the leading/trailing of a group token, try and enter it.
        if let newPoint = attemptEntry(insertionPoint: insertionPoint, goingLeft: goingLeft) {
            return newPoint
        }

        // Get the parent of the item
        guard let item = insertionPoint.treeLocation.pathComponents.last,
              let parent = tokenAt(location: insertionPoint.treeLocation.removingLastChild()),
              let parentGroup = parent.groupRepresentation else {
            print("Somehow this token has no parent")
            return insertionPoint
        }

        // Get the next child
        if let newPoint = attemptNextChild(
            insertionPoint: insertionPoint,
            parentGroup: parentGroup,
            item: item,
            goingLeft: goingLeft
        ) {
            return newPoint
        }

        return insertionPoint
    }

    private func insertionAtEdges(insertionPoint: InsertionPoint, goingLeft: Bool) -> InsertionPoint? {
        if goingLeft {
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
        } else {

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
        }

        return nil
    }

    private func insertionWithin(insertionPoint: InsertionPoint, goingLeft: Bool) -> InsertionPoint? {
        if insertionPoint.insertionLocation == .within {
            return .init(
                treeLocation: insertionPoint.treeLocation,
                insertionLocation: goingLeft ? .leading : .trailing
            )
        }
        return nil
    }

    private func attemptEntry(insertionPoint: InsertionPoint, goingLeft: Bool) -> InsertionPoint? {
        let referencePosition: InsertionPoint.InsertionLocation = goingLeft ? .trailing : .leading

        if insertionPoint.insertionLocation == referencePosition,
           let token = tokenAt(location: insertionPoint.treeLocation),
           let tokenGroup = token.groupRepresentation {
            if let child = goingLeft ? tokenGroup.lastChild() : tokenGroup.firstChild() {
                return .init(
                    treeLocation: insertionPoint.treeLocation.appending(child: child.id),
                    insertionLocation: referencePosition
                )
            } else {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: .within
                )
            }
        }

        return nil
    }

    private func attemptNextChild(
        insertionPoint: InsertionPoint,
        parentGroup: any GroupEquationToken,
        item: UUID,
        goingLeft: Bool
    ) -> InsertionPoint? {
        // The position that, if the item was enterable (if this function is called, it isn't), it would have entered
        let autoProceedReferencePosition: InsertionPoint.InsertionLocation = goingLeft ? .trailing : .leading
        // the other position
        let attemptEntryReferencePosition: InsertionPoint.InsertionLocation = goingLeft ? .leading : .trailing

        // Get the other child
        if let sibling = goingLeft ? parentGroup.child(leftOf: item) : parentGroup.child(rightOf: item) {
            // If the current insertion point is the autoProceedReferencePosition, go to that position of the next child
            if insertionPoint.insertionLocation == autoProceedReferencePosition {
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: sibling.id),
                    insertionLocation: autoProceedReferencePosition
                )
            }

            // else, try and enter the child
            if insertionPoint.insertionLocation == attemptEntryReferencePosition,
               let siblingGroup = sibling.groupRepresentation {
                if let child = goingLeft ? siblingGroup.lastChild() : siblingGroup.firstChild() {
                    return .init(
                        treeLocation: insertionPoint.treeLocation
                            .removingLastChild()
                            .appending(child: sibling.id)
                            .appending(child: child.id),
                        insertionLocation: autoProceedReferencePosition
                    )
                } else {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: sibling.id),
                        insertionLocation: .within
                    )
                }
            } else {
                // If it can't be entered, go to the attemptEntryReferencePosition of the child
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: sibling.id),
                    insertionLocation: attemptEntryReferencePosition
                )
            }
        } else {
            // If its the first or item in a group and a trailing/leading, go to the other position
            if insertionPoint.insertionLocation == autoProceedReferencePosition {
                return .init(
                    treeLocation: insertionPoint.treeLocation,
                    insertionLocation: attemptEntryReferencePosition
                )
            } else { // if its a attemptEntryReferencePosition, break out to the group's trailing
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastChild(),
                    insertionLocation: attemptEntryReferencePosition
                )
            }
        }
    }
}
