//
//  LinearGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation
import EditableEquationCore

/// A group token representing linear math. Most simple equations in traditional calculators are handled by LinearGroups
public struct LinearGroup: EquationToken {
    public var id: UUID = .init()
    public private(set) var name: String = "LinearGroup"

    public var contents: [any EquationToken]
    public var hasBrackets: Bool

    public init(id: UUID = .init(), contents: [any EquationToken], hasBrackets: Bool = false) {
        self.id = id
        self.contents = contents
        self.hasBrackets = hasBrackets
    }

    public func getLatex() -> String {
        if hasBrackets {
            "(\(contents.map({ $0.getLatex() }).joined()))"
        } else {
            contents.map({ $0.getLatex() }).joined()
        }
    }

    public func canPrecede(_ other: (any EquationToken)?) -> Bool {
        guard let other else { return true } // LinearGroups can always start or end groups
        if !hasBrackets { return false } // LinearGroups need brackets to go before others
        
        // LinearGroups can always precede operations
        if other is LinearOperationToken {
            return true
        }

        // LinearGroups can precede bracketed things
        if other.groupRepresentation?.canDirectlyMultiply() ?? false {
            return true
        }

        // Else, no
        return false
    }

    public func canSucceed(_ other: (any EquationToken)?) -> Bool {
        if other == nil { return true } // LinearGroups can always start or end groups
        if !hasBrackets { return false } // LinearGroups need brackets to go after others

        // LinearGroups can succeed pretty much anything
        return true
    }
}
