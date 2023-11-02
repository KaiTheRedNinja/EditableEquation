//
//  EquationManager+Validate.swift
//  
//
//  Created by Kai Quan Tay on 2/11/23.
//

import Foundation
import EditableEquationCore

extension EquationManager {
    public func updateErrors() {
        error = findErrors(in: root)
    }
}

extension EquationManager {
    /// Tries to find errors in the token. If it finds an error, it will return the TokenTreeLocation of the error,
    /// relative to the token. If there is no error, this function will return nil.
    private func findErrors(in token: any EquationToken) -> InsertionPoint? {
        if let groupRepresentation = token.groupRepresentation {
            // If the token is a group, check its childrens' individual validity
            var child = groupRepresentation.firstChild()

            // An empty group is always invalid
            guard child != nil else {
                return InsertionPoint(
                    treeLocation: .init(pathComponents: []),
                    insertionLocation: .within
                )
            }

            while let validChild = child {
                if let childError = findErrors(in: validChild) {
                    return childError.prepending(parent: validChild.id)
                }
                child = groupRepresentation.child(rightOf: validChild.id)
            }

            // Check if the children can exist together
            if groupRepresentation.validWhenChildrenValid() { return nil }

            var leftChild = groupRepresentation.firstChild()
            var rightChild = groupRepresentation.child(rightOf: leftChild!.id)

            // check that left child can be on the extreme left
            if let leftChild, leftChild.canSucceed(nil) == false {
                return InsertionPoint(
                    treeLocation: .init(pathComponents: [leftChild.id]),
                    insertionLocation: .trailing
                )
            }

            while let validLeftChild = leftChild, let validRightChild = rightChild {
                if validLeftChild.canPrecede(validRightChild) == false ||
                   validRightChild.canSucceed(validLeftChild) == false {
                    return InsertionPoint(
                        treeLocation: .init(pathComponents: [validLeftChild.id]),
                        insertionLocation: .trailing
                    )
                }

                leftChild = validRightChild
                rightChild = groupRepresentation.child(rightOf: validRightChild.id)
            }

            // check that right child can be on the extreme right
            if let lastChild = groupRepresentation.lastChild(),
               lastChild.canPrecede(nil) == false {
                return InsertionPoint(
                    treeLocation: .init(pathComponents: [lastChild.id]),
                    insertionLocation: .trailing
                )
            }
        }

        return nil
    }
}
