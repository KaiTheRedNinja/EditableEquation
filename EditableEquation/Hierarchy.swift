//
//  Hierarchy.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import Foundation

enum EquationToken: Identifiable, Codable {
    case number(NumberToken)
    case linearOperation(LinearOperationToken)

    case linearGroup(LinearGroup)

    var id: UUID {
        switch self {
        case .number(let numberToken): numberToken.id
        case .linearOperation(let operationToken): operationToken.id
        case .linearGroup(let linearGroup): linearGroup.id
        }
    }

    func optimised() -> EquationToken {
        switch self {
        case .linearGroup(let linearGroup):
            return .linearGroup(linearGroup.optimised())
        default: return self
        }
    }
}

struct NumberToken: Identifiable, Codable {
    var id: UUID = .init()

    var digit: Int
}

struct LinearOperationToken: Identifiable, Codable {
    var id: UUID = .init()

    var operation: LinearOperation

    enum LinearOperation: Codable {
        case plus, minus, times, divide
    }
}

struct LinearGroup: Identifiable, Codable {
    var id: UUID = .init()

    var contents: [EquationToken]

    /// Checks if the LinearGroup is valid
    func validate() -> Bool {
        // an empty linear group is invalid
        guard !contents.isEmpty else { return false }

        // 1. only one linear operation between any two non-linear-operation, unless the second and onwards operations are minus
        var lastTokenWasOperation: Bool = false

        for content in contents {
            switch content {
            case .linearOperation(let linearOperationToken):
                if lastTokenWasOperation == true && linearOperationToken.operation != .minus {
                    return false
                }
                lastTokenWasOperation = true
            default: lastTokenWasOperation = false
            }
        }

        // 2. the equation cannot start with an operation, except plus and minus
        switch contents.first! {
        case .linearOperation(let token):
            switch token.operation {
            case .minus, .plus: break
            default: return false
            }
        default: break
        }

        return true
    }

    /// Optimises the LinearGroup's representation. It returns a modified version of this instance, keeping the ID the same.
    /// This function is to be called every time the equation is modified, and has no effects on the equation's appearance.
    ///
    /// This works by turning consecutive number tokens into a single token
    func optimised() -> LinearGroup {
        var contentsCopy = contents
        // Iterate over the array backwards, to prevent access errors
        var lastNumberToken: Int? = nil

        for index in (0..<contentsCopy.count).reversed() {
            switch contentsCopy[index] {
            case .number(let number):
                if let lastNumberToken {
                    // get the last token, and integrate it into this token. Simple string concat.
                    contentsCopy.remove(at: index+1)
                    contentsCopy[index] = .number(NumberToken(digit: Int("\(number.digit)\(lastNumberToken)")!))
                }
                lastNumberToken = number.digit
            default:
                contentsCopy[index] = contentsCopy[index].optimised()
                lastNumberToken = nil
            }
        }

        return .init(id: self.id, contents: contentsCopy)
    }
}
