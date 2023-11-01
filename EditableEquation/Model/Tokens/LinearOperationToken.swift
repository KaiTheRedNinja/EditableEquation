//
//  LinearOperationToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct LinearOperationToken: SingleEquationToken {
    var id: UUID = .init()
    private(set) var name: String = "LinearOperation"

    var operation: LinearOperation

    enum LinearOperation: Codable {
        case plus, minus, times, divide
    }

    func canPrecede(_ other: (any SingleEquationToken)?) -> Bool {
        if let other {
            if let linearOperation = other as? LinearOperationToken {
                // A linear operation can only precede a minus operation
                return linearOperation.operation == .minus
            } else {
                // Linear operations can go before numbers, or pretty much any other token
                return true
            }
        } else {
            // Linear operations cannot be at the end of an equation
            return false
        }
    }

    func canSucceed(_ other: (any SingleEquationToken)?) -> Bool {
        if let other {
            if other is LinearOperationToken {
                return self.operation == .minus
            } else {
                // Linear operations can go after numbers, or pretty much any other token
                return true
            }
        } else {
            switch operation {
            case .plus, .minus:
                return true
            default:
                return false
            }
        }
    }
}
