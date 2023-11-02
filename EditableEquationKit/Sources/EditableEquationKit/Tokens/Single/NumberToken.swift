//
//  NumberToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation
import EditableEquationCore

/// A token representing a number
public struct NumberToken: EquationToken {
    public var id: UUID = .init()
    public private(set) var name: String = "Number"

    public var digit: Int

    public init(id: UUID = .init(), digit: Int) {
        self.id = id
        self.digit = digit
    }

    // number tokens can go pretty much anywhere
    public func canPrecede(_ other: (any EquationToken)?) -> Bool { true }

    public func canSucceed(_ other: (any EquationToken)?) -> Bool { true }
}
