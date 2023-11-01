//
//  EquationTokenProtocols.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 31/10/23.
//

import Foundation

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
    var groupRepresentation: (any GroupEquationToken)? {
        if self is (any GroupEquationToken) {
            print("\(name) is group")
            return self as? (any GroupEquationToken)
        }
        return nil
    }
}

public protocol GroupEquationToken: EquationToken {
    /// Returns a boolean representing, given all children token are valid, this token is valid.
    /// If `true` is returned, `canPrecede` and `canSucceed` will not be called on this token's children.
    func validWhenChildrenValid() -> Bool

    /// If the token can be multiplied with other tokens without a `*` in a LinearGroup.
    func canDirectlyMultiply() -> Bool

    /// Modifies the token to optimise its data representation, safe to call during any equation edit
    func optimised() -> any EquationToken

    /// Returns a boolean representing if the insertion location is valid. If it is invalid, it will be moved until it reaches a valid location.
    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool

    /// Inserts a token at an insertion point relative to the token
    func inserting(token: any EquationToken, at insertionPoint: InsertionPoint) -> any EquationToken

    /// Removes a token at a location relative to the token
    func removing(at location: TokenTreeLocation) -> any EquationToken

    /// Replaces the token at `location` with `token`
    func replacing(token: any EquationToken, at location: TokenTreeLocation) -> any EquationToken

    /// Returns the token for an ID representing a direct child within this group token, if it exists
    func child(with id: UUID) -> (any EquationToken)?

    /// Returns the token for an ID representing the child left of a direct child within this group token, if one exists
    func child(leftOf id: UUID) -> (any EquationToken)?

    /// Returns the token for an ID representing the child right of a direct child within this group token, if one exists
    func child(rightOf id: UUID) -> (any EquationToken)?

    /// Returns the first child
    func firstChild() -> (any EquationToken)?

    /// Returns the last child
    func lastChild() -> (any EquationToken)?
}
