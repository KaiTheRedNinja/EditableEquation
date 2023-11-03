//
//  ValueEquationToken.swift
//
//
//  Created by Kai Quan Tay on 3/11/23.
//

import Foundation

public protocol ValueEquationToken: EquationToken {
    func solved() -> Solution
}
