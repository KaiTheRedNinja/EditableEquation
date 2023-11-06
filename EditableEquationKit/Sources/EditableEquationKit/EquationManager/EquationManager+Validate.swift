//
//  EquationManager+Validate.swift
//  
//
//  Created by Kai Quan Tay on 2/11/23.
//

import Foundation
import EditableEquationCore

public extension EquationManager {
    /// Updates the ``error`` value
    func updateErrors() {
        error = findErrors(in: root)
    }
}

public struct EquationError: Error {
    public var insertionPoint: InsertionPoint
    public var error: EquationErrorDetails

    public enum EquationErrorDetails {
        case unknownSingleToken(String)

        case cannotBeEmpty(String)
        case cannotStartGroup(String)
        case cannotEndGroup(String)
        case cannotCoexist(String, String)

        public var description: String {
            switch self {
            case .unknownSingleToken(let string):
                "unknown token: \(string)"
            case .cannotBeEmpty(let string):
                "\(string) cannot be empty"
            case .cannotStartGroup(let string):
                "\(string) cannot be at the start"
            case .cannotEndGroup(let string):
                "\(string) cannot be at the end"
            case let .cannotCoexist(string1, string2):
                "\(string1) and \(string2) cannot be next to each other"
            }
        }
    }

    public func prepending(parent: UUID) -> EquationError {
        return .init(
            insertionPoint: insertionPoint.prepending(parent: parent),
            error: error
        )
    }
}

extension EquationManager {
    /// Tries to find errors in the token. If it finds an error, it will return the TokenTreeLocation of the error,
    /// relative to the token. If there is no error, this function will return nil.
    private func findErrors(in token: any EquationToken) -> EquationError? {
        guard let groupRepresentation = token.groupRepresentation else { return nil }

        // If the token is a group, check its childrens' individual validity
        var child = groupRepresentation.firstChild()

        // An empty group is always invalid
        guard child != nil else {
            return .init(
                insertionPoint: .init(
                    treeLocation: .init(pathComponents: []),
                    insertionLocation: .within
                ),
                error: .cannotBeEmpty(token.name)
            )
        }

        // find errors in the token's children
        while let validChild = child {
            if let childError = findErrors(in: validChild) {
                return childError.prepending(parent: validChild.id)
            }
            child = groupRepresentation.child(rightOf: validChild.id)
        }

        // Check if the children can exist together
        if let childrenCoexistenceError = childrenCanCoexist(groupRepresentation: groupRepresentation) {
            return childrenCoexistenceError
        }

        // else, return nil
        return nil
    }

    func childrenCanCoexist(groupRepresentation: any GroupEquationToken) -> EquationError? {
        if groupRepresentation.validWhenChildrenValid() { return nil }

        var leftChild = groupRepresentation.firstChild()
        var rightChild = groupRepresentation.child(rightOf: leftChild!.id)

        // check that left child can be on the extreme left
        if let leftChild, leftChild.canSucceed(nil) == false {
            return .init(
                insertionPoint: .init(
                    treeLocation: .init(pathComponents: [leftChild.id]),
                    insertionLocation: .trailing
                ),
                error: .cannotStartGroup(leftChild.name)
            )
        }

        while let validLeftChild = leftChild, let validRightChild = rightChild {
            if validLeftChild.canPrecede(validRightChild) == false ||
                validRightChild.canSucceed(validLeftChild) == false {
                return .init(
                    insertionPoint: .init(
                        treeLocation: .init(pathComponents: [validRightChild.id]),
                        insertionLocation: .leading
                    ),
                    error: .cannotCoexist(validLeftChild.name, validRightChild.name)
                )
            }

            leftChild = validRightChild
            rightChild = groupRepresentation.child(rightOf: validRightChild.id)
        }

        // check that right child can be on the extreme right
        if let lastChild = groupRepresentation.lastChild(),
           lastChild.canPrecede(nil) == false {
            return .init(
                insertionPoint: .init(
                    treeLocation: .init(pathComponents: [lastChild.id]),
                    insertionLocation: .trailing
                ),
                error: .cannotEndGroup(lastChild.name)
            )
        }

        return nil
    }
}
