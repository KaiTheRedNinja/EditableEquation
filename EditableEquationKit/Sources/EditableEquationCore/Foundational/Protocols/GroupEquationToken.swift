//
//  GroupEquationToken.swift
//
//
//  Created by Kai Quan Tay on 3/11/23.
//

import Foundation

/// A protocol for a token containing other tokens
///
/// Implement this protocol to add custom tokens that contain other tokens.
public protocol GroupEquationToken: ValueEquationToken {
    // MARK: Mandatory functions

    /// Returns a boolean representing if the insertion location is valid. If it is invalid, it will be moved until it
    /// reaches a valid location.
    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool

    /// Inserts a token at an insertion point relative to a child in the token
    ///
    /// If the `insertionLocation` is `.within`, *DISREGARD* the `referenceTokenID`, as it 
    /// is referring to the token itself, not any children.
    /// This case will only occur when there are no children, and as such `referenceTokenID` will be `nil`.
    func inserting(
        token: any EquationToken,
        at insertionLocation: InsertionPoint.InsertionLocation,
        relativeToID referenceTokenID: UUID!
    ) -> any EquationToken

    /// Removes a child token.
    /// If the action of removing the child token removes the token itself, return `nil`
    func removing(
        childID: UUID
    ) -> (any EquationToken)?

    /// Replaces the child token with ID `originalTokenID` with `newToken`
    func replacing(
        originalTokenID: UUID,
        with newToken: any EquationToken
    ) -> any EquationToken

    /// Returns the token for an ID representing a direct child within this group token, if it exists
    func child(with id: UUID) -> (any EquationToken)?

    /// Returns the token for an ID representing the child left of a direct child within this group token, if one exists
    func child(leftOf id: UUID) -> (any EquationToken)?

    /// Returns the token for an ID representing the child right of a direct child within 
    /// this group token, if one exists
    func child(rightOf id: UUID) -> (any EquationToken)?

    /// Returns the first child, if one exists
    func firstChild() -> (any EquationToken)?

    /// Returns the last child, if one exists
    func lastChild() -> (any EquationToken)?

    // MARK: Optional methods

    /// Returns a boolean representing, given all children token are valid, this token is valid.
    /// If `true` is returned, `canPrecede` and `canSucceed` will not be called on this token's children.
    ///
    /// Defaults to true
    func validWhenChildrenValid() -> Bool

    /// If the token can be multiplied with other tokens without a `*` in a LinearGroup.
    ///
    /// Defaults to false
    func canDirectlyMultiply() -> Bool

    /// Modifies the token to optimise its data representation, safe to call during any equation edit
    ///
    /// Defaults to optimising and replacing all the children
    func optimised() -> any EquationToken
}

public extension GroupEquationToken {
    func validWhenChildrenValid() -> Bool { true }

    func canDirectlyMultiply() -> Bool { false }

    func optimised() -> any EquationToken {
        var newChildren: [(UUID, any EquationToken)] = []

        var mutableSelf: any EquationToken = self

        // optimise the children
        var child = firstChild()
        while let validChild = child {
            newChildren.append((
                validChild.id,
                validChild.groupRepresentation?.optimised() ?? validChild
            ))

            child = self.child(rightOf: validChild.id)
        }

        // replace the children
        for (originalID, newChild) in newChildren {
            mutableSelf = mutableSelf.groupRepresentation?.replacing(
                originalTokenID: originalID,
                with: newChild
            ) ?? mutableSelf
        }

        return mutableSelf
    }
}
