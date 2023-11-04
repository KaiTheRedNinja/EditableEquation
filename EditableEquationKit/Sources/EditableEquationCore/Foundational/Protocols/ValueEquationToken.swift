//
//  ValueEquationToken.swift
//
//
//  Created by Kai Quan Tay on 3/11/23.
//

import Foundation

public protocol ValueEquationToken: EquationToken {
    /// Gets the solved value of the token.
    ///
    /// Only to be called *AFTER* the token is validated, or it may cause fatal errors
    func solved() throws -> Double
}
