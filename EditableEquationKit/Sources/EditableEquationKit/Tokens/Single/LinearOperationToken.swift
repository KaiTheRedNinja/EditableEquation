//
//  LinearOperationToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation
import EditableEquationCore

public struct LinearOperationToken: SingleEquationToken {
    public var id: UUID = .init()
    public private(set) var name: String = "LinearOperation"

    public var operation: LinearOperation

    public init(id: UUID = .init(), operation: LinearOperation) {
        self.id = id
        self.operation = operation
    }

    public enum LinearOperation: Codable {
        case plus, minus, times, divide
    }

    public func canPrecede(_ other: (any SingleEquationToken)?) -> Bool {
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

    public func canSucceed(_ other: (any SingleEquationToken)?) -> Bool {
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
