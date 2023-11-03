//
//  EquationToken.swift
//
//
//  Created by Kai Quan Tay on 3/11/23.
//

import Foundation

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
    /// If the other token is nil, it is asking if the token can be last in the group.
    ///
    /// Defaults to true
    func canPrecede(_ other: (any EquationToken)?) -> Bool

    /// Returns a boolean representing if this token can go after another token
    /// If the other token is nil, it is asking if the token can be first in the group.
    ///
    /// Defaults to true
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

    // default implementations
    func canPrecede(_ other: (any EquationToken)?) -> Bool { true }
    func canSucceed(_ other: (any EquationToken)?) -> Bool { true }
}
