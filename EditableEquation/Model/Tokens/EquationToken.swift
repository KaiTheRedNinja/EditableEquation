//
//  EquationToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

protocol SingleEquationToken: Identifiable, Codable {}

protocol GroupEquationToken: SingleEquationToken {
    /// Returns a boolean value representing if the token is in the correct format
    func validate() -> Bool

    /// Modifies the token to optimise its data representation, safe to call during any equation edit
    func optimised() -> Self

    /// Inserts a token at an insertion point relative to the token
    func inserting(token: EquationToken, at insertionPoint: InsertionPoint) -> Self

    /// Removes a token at a location relative to the token
    func removing(at location: TokenTreeLocation) -> Self
}

enum EquationToken: Identifiable, Codable {
    case number(NumberToken)
    case linearOperation(LinearOperationToken)
    case linearGroup(LinearGroup)

    var id: UUID {
        switch self {
        case .number(let numberToken): numberToken.id
        case .linearOperation(let operationToken): operationToken.id
        case .linearGroup(let linearGroup): linearGroup.id
        }
    }

    func optimised() -> EquationToken {
        switch self {
        case .linearGroup(let linearGroup):
            return .linearGroup(linearGroup.optimised())
        default:
            return self
        }
    }
}
