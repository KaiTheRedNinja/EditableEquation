//
//  EquationToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

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

    func replacing(token: EquationToken, at location: TokenTreeLocation) -> EquationToken {
        switch self {
        case .number, .linearOperation:
            return self
        case .linearGroup(let linearGroup):
            return .linearGroup(linearGroup.replacing(token: token, at: location))
        case .divisionGroup(let divisionGroup):
            return .divisionGroup(divisionGroup.replacing(token: token, at: location))
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
