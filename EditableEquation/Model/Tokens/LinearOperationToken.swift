//
//  LinearOperationToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct LinearOperationToken: SingleEquationToken {
    var id: UUID = .init()

    var operation: LinearOperation

    enum LinearOperation: Codable {
        case plus, minus, times, divide
    }
}
