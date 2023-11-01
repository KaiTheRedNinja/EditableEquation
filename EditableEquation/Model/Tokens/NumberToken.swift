//
//  NumberToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct NumberToken: SingleEquationToken {
    var id: UUID = .init()
    private(set) var name: String = "Number"

    var digit: Int

    // number tokens can go pretty much anywhere
    func canPrecede(_ other: (any SingleEquationToken)?) -> Bool { true }

    func canSucceed(_ other: (any SingleEquationToken)?) -> Bool { true }
}
