//
//  NumberToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct NumberToken: SingleEquationToken {
    var id: UUID = .init()

    var digit: Int

    // number tokens can go pretty much anywhere
    func canPrecede(_ other: EquationToken?) -> Bool { true }

    func canSucceed(_ other: EquationToken?) -> Bool { true }
}
