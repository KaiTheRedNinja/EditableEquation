//
//  LinearGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct LinearGroup: GroupEquationToken {
    var id: UUID = .init()

    var contents: [EquationToken]
    var hasBrackets: Bool

    init(id: UUID = .init(), contents: [EquationToken], hasBrackets: Bool = false) {
        self.id = id
        self.contents = contents
        self.hasBrackets = hasBrackets
    }

    /// Checks if the LinearGroup is valid. Assumes the LinearGroup is optimised.
    func validate() -> Bool {
        // an empty linear group is invalid
        guard !contents.isEmpty else { return false }

        // 1. only one linear operation between any two non-linear-operation, unless the second and onwards operations are minus
        // 2. all subtokens must be valid
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

            if !(content.groupRepresentation?.validate() ?? true) {
                return false
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
    func optimised() -> LinearGroup {
        var contentsCopy = contents

        // optimise everything
        for index in 0..<contentsCopy.count {
            contentsCopy[index] = contentsCopy[index].optimised()
        }

        // For some of these, we iterate over the array backwards, to prevent access errors

        // break out non-bracket LinearGroups
        for index in (0..<contentsCopy.count).reversed() {
            switch contentsCopy[index] {
            case .linearGroup(let linearGroup):
                if !linearGroup.hasBrackets {
                    contentsCopy.remove(at: index)
                    contentsCopy.insert(contentsOf: linearGroup.optimised().contents, at: index)
                }
            default: continue
            }
        }

        // Turn consecutive number tokens into a single token
        var lastNumberToken: Int? = nil
        for index in (0..<contentsCopy.count).reversed() {
            switch contentsCopy[index] {
            case .number(let number):
                if let lastNumberToken {
                    // get the last token, and integrate it into this token. Simple string concat.
                    contentsCopy.remove(at: index+1)

                    let lastNumberTokenMagnitude = Int(log(Double(lastNumberToken))/log(10))

                    let newDigit = lastNumberToken + number.digit * Int(pow(10, Double(1 + lastNumberTokenMagnitude)))

                    contentsCopy[index] = .number(
                        NumberToken(
                            id: contentsCopy[index].id,
                            digit: newDigit
                        )
                    )
                }
                lastNumberToken = number.digit
            default:
                lastNumberToken = nil
            }
        }

        return .init(id: self.id, contents: contentsCopy, hasBrackets: self.hasBrackets)
    }

    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool {
        switch insertionLocation {
        case .leading, .trailing:
            return hasBrackets
        case .within:
            return contents.isEmpty
        }
    }

    func inserting(token: EquationToken, at insertionPoint: InsertionPoint) -> LinearGroup {
        var mutableSelf = self

        guard let id = insertionPoint.treeLocation.pathComponents.first,
              let insertionIndex = contents.firstIndex(where: { $0.id == id })
        else { return mutableSelf }

        // If theres only one item in the path, its a direct child of this linear group
        if insertionPoint.treeLocation.pathComponents.count == 1 {
            switch insertionPoint.insertionLocation {
            case .leading:
                mutableSelf.contents.insert(token, at: insertionIndex)
            case .trailing:
                mutableSelf.contents.insert(token, at: insertionIndex+1)
            case .within:
                switch mutableSelf.contents[insertionIndex] {
                case .linearGroup(var group):
                    guard group.contents.isEmpty else { return mutableSelf }
                    group.contents = [token]
                    mutableSelf.contents[insertionIndex] = .linearGroup(group)
                default: return mutableSelf
                }
            }

            return mutableSelf
        }

        // Else, there must be more. Recursively call the function.
        // TODO: Update this to not be a switch case, and instead do type casting or smth like that
        switch mutableSelf.contents[insertionIndex] {
        case .linearGroup(let linearGroup):
            mutableSelf.contents[insertionIndex] = .linearGroup(linearGroup.inserting(
                token: token,
                at: .init(
                    treeLocation: insertionPoint.treeLocation.removingFirstPathComponent(),
                    insertionLocation: insertionPoint.insertionLocation)
                )
            )
        case .divisionGroup(let divisionGroup):
            mutableSelf.contents[insertionIndex] = .divisionGroup(divisionGroup.inserting(
                token: token,
                at: .init(
                    treeLocation: insertionPoint.treeLocation.removingFirstPathComponent(),
                    insertionLocation: insertionPoint.insertionLocation)
                )
            )
        default: return mutableSelf
        }

        return mutableSelf
    }

    func removing(at location: TokenTreeLocation) -> LinearGroup {
        var mutableSelf = self

        guard let id = location.pathComponents.first,
              let removalIndex = mutableSelf.contents.firstIndex(where: { $0.id == id })
        else { return mutableSelf }

        // If theres only one item in the path, its a direct child of this linear group
        if location.pathComponents.count == 1 {
            mutableSelf.contents.remove(at: removalIndex)

            return mutableSelf
        }

        // Else, there must be more. Recursively call the function.
        switch mutableSelf.contents[removalIndex] {
        case .linearGroup(let linearGroup):
            mutableSelf.contents[removalIndex] = .linearGroup(linearGroup.removing(
                at: location.removingFirstPathComponent()
            ))
        default: return mutableSelf
        }

        return mutableSelf
    }

    func child(with id: UUID) -> EquationToken? {
        return contents.first(where: { $0.id == id })
    }

    func child(leftOf id: UUID) -> EquationToken? {
        guard let index = contents.firstIndex(where: { $0.id == id }), index > 0 else { return nil }
        return contents[index-1]
    }

    func child(rightOf id: UUID) -> EquationToken? {
        guard let index = contents.firstIndex(where: { $0.id == id }), index < contents.count-1 else { return nil }
        return contents[index+1]
    }

    func firstChild() -> EquationToken? {
        contents.first
    }

    func lastChild() -> EquationToken? {
        contents.last
    }
}
