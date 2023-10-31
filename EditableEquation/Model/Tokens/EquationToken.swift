//
//  EquationToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

protocol SingleEquationToken: Identifiable, Codable {
    /// Returns a boolean representing if this token can go before another toke
    /// If the other token is nil, it is asking if the token can be last in the group
    func canPrecede(_ other: EquationToken?) -> Bool

    /// Returns a boolean representing if this token can go after another token
    /// If the other token is nil, it is asking if the token can be first in the group
    func canSucceed(_ other: EquationToken?) -> Bool
}

protocol GroupEquationToken: SingleEquationToken {
    /// Returns a boolean representing, given all children token are valid, this token is valid.
    /// If `true` is returned, `canPrecede` and `canSucceed` will not be called on this token's children.
    func validWhenChildrenValid() -> Bool

    /// If the token can be multiplied with other  tokens without a `*` in a LinearGroup.
    func canDirectlyMultiply() -> Bool

    /// Modifies the token to optimise its data representation, safe to call during any equation edit
    func optimised() -> Self

    /// Returns a boolean representing if the insertion location is valid. If it is invalid, it will be moved until it reaches a valid location.
    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool

    /// Inserts a token at an insertion point relative to the token
    func inserting(token: EquationToken, at insertionPoint: InsertionPoint) -> Self

    /// Removes a token at a location relative to the token
    func removing(at location: TokenTreeLocation) -> Self

    /// Returns the token for an ID representing a direct child within this group token, if it exists
    func child(with id: UUID) -> EquationToken?

    /// Returns the token for an ID representing the child left of a direct child within this group token, if one exists
    func child(leftOf id: UUID) -> EquationToken?

    /// Returns the token for an ID representing the child right of a direct child within this group token, if one exists
    func child(rightOf id: UUID) -> EquationToken?

    /// Returns the first child
    func firstChild() -> EquationToken?

    /// Returns the last child
    func lastChild() -> EquationToken?
}

enum EquationToken: Identifiable, Codable {
    case number(NumberToken)
    case linearOperation(LinearOperationToken)
    case linearGroup(LinearGroup)
    case divisionGroup(DivisionGroup)

    var id: UUID {
        switch self {
        case .number(let numberToken): numberToken.id
        case .linearOperation(let operationToken): operationToken.id
        case .linearGroup(let linearGroup): linearGroup.id
        case .divisionGroup(let divisionGroup): divisionGroup.id
        }
    }

    func optimised() -> EquationToken {
        switch self {
        case .linearGroup(let linearGroup):
            return .linearGroup(linearGroup.optimised())
        case .divisionGroup(let divisionGroup):
            return .divisionGroup(divisionGroup.optimised())
        default:
            return self
        }
    }

    func canPrecede(_ other: EquationToken?) -> Bool {
        switch self {
        case .number(let numberToken):
            numberToken.canPrecede(other)
        case .linearOperation(let linearOperationToken):
            linearOperationToken.canPrecede(other)
        case .linearGroup(let linearGroup):
            linearGroup.canPrecede(other)
        case .divisionGroup(let divisionGroup):
            divisionGroup.canPrecede(other)
        }
    }
    func canSucceed(_ other: EquationToken?) -> Bool {
        switch self {
        case .number(let numberToken):
            numberToken.canSucceed(other)
        case .linearOperation(let linearOperationToken):
            linearOperationToken.canSucceed(other)
        case .linearGroup(let linearGroup):
            linearGroup.canSucceed(other)
        case .divisionGroup(let divisionGroup):
            divisionGroup.canSucceed(other)
        }
    }

    func inserting(token: EquationToken, at insertionPoint: InsertionPoint) -> EquationToken {
        switch self {
        case .number, .linearOperation:
            return self
        case .linearGroup(let linearGroup):
            return .linearGroup(linearGroup.inserting(token: token, at: insertionPoint))
        case .divisionGroup(let divisionGroup):
            return .divisionGroup(divisionGroup.inserting(token: token, at: insertionPoint))
        }
    }

    func removing(at location: TokenTreeLocation) -> EquationToken {
        switch self {
        case .number, .linearOperation:
            return self
        case .linearGroup(let linearGroup):
            return .linearGroup(linearGroup.removing(at: location))
        case .divisionGroup(let divisionGroup):
            return .divisionGroup(divisionGroup.removing(at: location))
        }
    }

    var groupRepresentation: (any GroupEquationToken)? {
        switch self {
        case .linearGroup(let linearGroup):
            return linearGroup
        case .divisionGroup(let divisionGroup):
            return divisionGroup
        default:
            return nil
        }
    }
}
