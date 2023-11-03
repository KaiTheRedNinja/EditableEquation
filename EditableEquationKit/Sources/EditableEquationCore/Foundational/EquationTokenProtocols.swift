//
//  EquationTokenProtocols.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 31/10/23.
//

import Foundation

// TODO: Solving the equation

/// A protocol for a token in an equation.
///
/// It is not advised to implement this protocol. Instead, implement ``GroupEquationToken``.
///
/// EditableEquationKit only expects `NumberToken` or `LinearOperationToken` to conform to only `EquationToken`,
/// and any custom `EquationToken`s may have unexpected behaviour.
public protocol EquationToken: Identifiable, Codable where ID == UUID {
    /// This should be a string unique to the *type*. For example, all `NumberToken`s should have the same `name`.
    /// `name` cannot be a computed property nor immutable, as it needs to be encoded and decoded.
    var name: String { get }

    /// Returns a boolean representing if this token can go before another toke
    /// If the other token is nil, it is asking if the token can be last in the group
    func canPrecede(_ other: (any EquationToken)?) -> Bool

    /// Returns a boolean representing if this token can go after another token
    /// If the other token is nil, it is asking if the token can be first in the group
    func canSucceed(_ other: (any EquationToken)?) -> Bool
}

public extension EquationToken {
    /// Type casts the `EquationToken` to a ``GroupEquationToken``, if possible.
    var groupRepresentation: (any GroupEquationToken)? {
        if self is (any GroupEquationToken) {
            return self as? (any GroupEquationToken)
        }
        return nil
    }
}

/// A protocol for a token containing other tokens
///
/// Implement this protocol to add custom tokens that contain other tokens.
public protocol GroupEquationToken: EquationToken {
    // TODO: Make these Optional functions

    /// Returns a boolean representing, given all children token are valid, this token is valid.
    /// If `true` is returned, `canPrecede` and `canSucceed` will not be called on this token's children.
    func validWhenChildrenValid() -> Bool

    /// If the token can be multiplied with other tokens without a `*` in a LinearGroup.
    func canDirectlyMultiply() -> Bool

    /// Modifies the token to optimise its data representation, safe to call during any equation edit
    func optimised() -> any EquationToken

    // MARK: Mandatory functions

    /// Returns a boolean representing if the insertion location is valid. If it is invalid, it will be moved until it reaches a valid location.
    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool

    /// Inserts a token at an insertion point relative to a child in the token
    ///
    /// If the `insertionLocation` is `.within`, *DISREGARD* the `referenceTokenID`, as it is referring to the token itself, not any children.
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

    /// Returns the token for an ID representing the child right of a direct child within this group token, if one exists
    func child(rightOf id: UUID) -> (any EquationToken)?

    /// Returns the first child, if one exists
    func firstChild() -> (any EquationToken)?

    /// Returns the last child, if one exists
    func lastChild() -> (any EquationToken)?
}
