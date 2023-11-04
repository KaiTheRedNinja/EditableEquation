//
//  NumberToken.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation
import EditableEquationCore
import Rationals

/// A token representing a number
public struct NumberToken: ValueEquationToken {
    public func getLatex() -> String {
        String(digit)
    }

    public func solved() throws -> Fraction<Int> {
        Fraction(integerLiteral: digit)
    }
    
    public var id: UUID = .init()
    public private(set) var name: String = "Number"

    public var digit: Int

    public init(id: UUID = .init(), digit: Int) {
        self.id = id
        self.digit = digit
    }
}
