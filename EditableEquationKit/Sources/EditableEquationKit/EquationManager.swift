//
//  EquationManager.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 29/10/23.
//

import Foundation
import EditableEquationCore

public class EquationManager: ObservableObject {
    @Published public private(set) var root: LinearGroup
    @Published public var insertionPoint: InsertionPoint?

    public init(root: LinearGroup) {
        self.root = root

        // register all the types for use
        EquationTokenCoding.register(type: NumberToken.self, for: "Number")
        EquationTokenCoding.register(type: LinearOperationToken.self, for: "LinearOperation")
        EquationTokenCoding.register(type: LinearGroup.self, for: "LinearGroup")
        EquationTokenCoding.register(type: DivisionGroup.self, for: "DivisionGroup")
    }

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

    public func insert(token: any EquationToken, at insertionPoint: InsertionPoint) {
        root = (root.inserting(token: token, at: insertionPoint) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
    }

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
    }

    public func remove(at location: TokenTreeLocation) {
        root = (root.removing(at: location) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
    }

    public func replace(token: any EquationToken, at location: TokenTreeLocation) {
        root = (root.replacing(token: token, at: location) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
    }

    public func move(from initialLocation: TokenTreeLocation, to insertionPoint: InsertionPoint) {
        guard let token = tokenAt(location: initialLocation) else { return }
        root = (root.removing(at: initialLocation) as? LinearGroup) ?? root
        root = (root.inserting(token: token, at: insertionPoint) as? LinearGroup) ?? root
        root = (root.optimised() as? LinearGroup) ?? root
    }

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

    public func validate(token: (any EquationToken)) -> Bool {
        if let groupRepresentation = token.groupRepresentation {
            // If the token is a group, check its childrens' individual validity
            var child = groupRepresentation.firstChild()

            // An empty group is always invalid
            guard child != nil else { return false }

            while let validChild = child {
                if validate(token: validChild) == false { return false }
                child = groupRepresentation.child(rightOf: validChild.id)
            }

            // Check if the children can exist together
            if groupRepresentation.validWhenChildrenValid() { return true }

            var leftChild = groupRepresentation.firstChild()
            var rightChild = groupRepresentation.child(rightOf: leftChild!.id)

            // check that left child can be on the extreme left
            if leftChild?.canSucceed(nil) == false {
                return false
            }

            while let validLeftChild = leftChild, let validRightChild = rightChild {
                if validLeftChild.canPrecede(validRightChild) == false ||
                    validRightChild.canSucceed(validLeftChild) == false {
                    return false
                }

                leftChild = validRightChild
                rightChild = groupRepresentation.child(rightOf: validRightChild.id)
            }

            // check that right child can be on the extreme right
            if groupRepresentation.lastChild()?.canPrecede(nil) == false {
                return false
            }
        }

        return true
    }
}

extension EquationManager {
    private func tokenAt(location: TokenTreeLocation) -> (any EquationToken)? {
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
    private func tokenLeading(location: TokenTreeLocation) -> (any EquationToken)? {
        var currentToken: any EquationToken = root

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(leftOf: lastItem)
    }

    /// The token to the right of the location, if it exists
    private func tokenTrailing(location: TokenTreeLocation) -> (any EquationToken)? {
        var currentToken: any EquationToken = root

        guard let lastItem = location.pathComponents.last else { return nil }

        for component in location.pathComponents.dropLast(1) {
            guard let newCurrentToken = currentToken.groupRepresentation?.child(with: component) else { return nil }
            currentToken = newCurrentToken
        }

        return currentToken.groupRepresentation?.child(rightOf: lastItem)
    }

    /// The new insertion point if moved to the left
    private func insertionLeft(of insertionPoint: InsertionPoint) -> InsertionPoint {
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
                    treeLocation: insertionPoint.treeLocation.adding(pathComponent: lastChild.id),
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
              let parent = tokenAt(location: insertionPoint.treeLocation.removingLastPathComponent()),
              let parentGroup = parent.groupRepresentation else {
            print("Somehow this token has no parent")
            return insertionPoint
        }

        // Get the previous child
        if let prevChild = parentGroup.child(leftOf: item) {
            // If the current insertion point is a trailng, go to the trailing of the previous child
            if insertionPoint.insertionLocation == .trailing {
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: prevChild.id),
                    insertionLocation: .trailing
                )
            }

            // If the current insertion point is a leading, try and enter the child
            if insertionPoint.insertionLocation == .leading,
               let childGroup = prevChild.groupRepresentation {
                if let lastChild = childGroup.lastChild() {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: prevChild.id).adding(pathComponent: lastChild.id),
                        insertionLocation: .trailing
                    )
                } else {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: prevChild.id),
                        insertionLocation: .within
                    )
                }
            } else {
                // If it can't be entered, go to the leading of the child
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: prevChild.id),
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
                    treeLocation: insertionPoint.treeLocation.removingLastPathComponent(),
                    insertionLocation: .leading
                )
            }
        }
    }

    /// The new insertion point if moved to the right
    private func insertionRight(of insertionPoint: InsertionPoint) -> InsertionPoint {
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
                    treeLocation: insertionPoint.treeLocation.adding(pathComponent: firstChild.id),
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
              let parent = tokenAt(location: insertionPoint.treeLocation.removingLastPathComponent()),
              let parentGroup = parent.groupRepresentation else {
            print("Somehow this token has no parent")
            return insertionPoint
        }

        // Get the next child
        if let nextChild = parentGroup.child(rightOf: item) {
            // If the current insertion point is a leading, go to the leading of the next child
            if insertionPoint.insertionLocation == .leading {
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: nextChild.id),
                    insertionLocation: .leading
                )
            }

            // If the current insertion point is a trailing, try and enter the child
            if insertionPoint.insertionLocation == .trailing,
                let childGroup = nextChild.groupRepresentation {
                if let firstChild = childGroup.firstChild() {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: nextChild.id).adding(pathComponent: firstChild.id),
                        insertionLocation: .leading
                    )
                } else {
                    return .init(
                        treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: nextChild.id),
                        insertionLocation: .within
                    )
                }
            } else {
                // If it can't be entered, go to the trailing of the child
                return .init(
                    treeLocation: insertionPoint.treeLocation.removingLastPathComponent().adding(pathComponent: nextChild.id),
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
                    treeLocation: insertionPoint.treeLocation.removingLastPathComponent(),
                    insertionLocation: .trailing
                )
            }
        }
    }
}
