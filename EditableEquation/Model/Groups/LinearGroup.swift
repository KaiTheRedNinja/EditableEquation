//
//  LinearGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct LinearGroup: GroupEquationToken {
    var id: UUID = .init()
    private(set) var name: String = "LinearGroup"

    var contents: [EquationToken]
    var hasBrackets: Bool

    init(id: UUID = .init(), contents: [EquationToken], hasBrackets: Bool = false) {
        self.id = id
        self.contents = contents
        self.hasBrackets = hasBrackets
    }

    func canPrecede(_ other: EquationToken?) -> Bool {
        guard let other else { return true } // LinearGroups can always start or end groups
        if !hasBrackets { return false } // LinearGroups need brackets to go before others
        
        // LinearGroups can always precede operations
        switch other {
        case .linearOperation:
            return true
        default: break
        }

        // LinearGroups can precede bracketed things
        if other.groupRepresentation?.canDirectlyMultiply() ?? false {
            return true
        }

        // Else, no
        return false
    }

    func canSucceed(_ other: EquationToken?) -> Bool {
        guard let other else { return true } // LinearGroups can always start or end groups
        if !hasBrackets { return false } // LinearGroups need brackets to go after others

        // LinearGroups can always succeed operations
        switch other {
        case .linearOperation:
            return true
        default: break
        }

        // LinearGroups can succeed bracketed things
        if other.groupRepresentation?.canDirectlyMultiply() ?? false {
            return true
        }

        // Else, no
        return false
    }

    func validWhenChildrenValid() -> Bool { false }
    func canDirectlyMultiply() -> Bool { hasBrackets }

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
        mutableSelf.contents[insertionIndex] = mutableSelf.contents[insertionIndex].inserting(
            token: token,
            at: .init(
                treeLocation: insertionPoint.treeLocation.removingFirstPathComponent(),
                insertionLocation: insertionPoint.insertionLocation
            )
        )

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
        mutableSelf.contents[removalIndex] = mutableSelf.contents[removalIndex].removing(
            at: location.removingFirstPathComponent()
        )

        return mutableSelf
    }

    func replacing(token: EquationToken, at location: TokenTreeLocation) -> LinearGroup {
        var mutableSelf = self

        guard let id = location.pathComponents.first,
              let replacementIndex = mutableSelf.contents.firstIndex(where: { $0.id == id })
        else { return mutableSelf }

        // If theres only one item in the path, its a direct child of this linear group
        if location.pathComponents.count == 1 {
            mutableSelf.contents[replacementIndex] = token

            return mutableSelf
        }

        // Else, there must be more. Recursively call the function.
        mutableSelf.contents[replacementIndex] = mutableSelf.contents[replacementIndex].replacing(
            token: token,
            at: location.removingFirstPathComponent()
        )

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
