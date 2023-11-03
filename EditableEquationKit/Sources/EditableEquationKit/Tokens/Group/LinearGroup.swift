//
//  LinearGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation
import EditableEquationCore

/// A group token representing linear math. Most simple equations in traditional calculators are handled by LinearGroups
public struct LinearGroup: GroupEquationToken {
    public var id: UUID = .init()
    public private(set) var name: String = "LinearGroup"

    public var contents: [any EquationToken]
    public var hasBrackets: Bool

    public init(id: UUID = .init(), contents: [any EquationToken], hasBrackets: Bool = false) {
        self.id = id
        self.contents = contents
        self.hasBrackets = hasBrackets
    }

    // MARK: Codable
    public enum Keys: CodingKey {
        case name, contents, hasBrackets
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(name, forKey: .name)
        try container.encode(contents.stringEncoded()?.data(using: .utf8), forKey: .contents)
        try container.encode(hasBrackets, forKey: .hasBrackets)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let contentsData = try container.decode(Data.self, forKey: .contents)
        guard let contentsString = String(data: contentsData, encoding: .utf8),
              let contents = [any EquationToken](decoding: contentsString)
        else {
            throw DecodingError.valueNotFound(
                Data.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "No contents found"
                )
            )
        }
        self.contents = contents
        self.hasBrackets = try container.decode(Bool.self, forKey: .hasBrackets)
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

    public func validWhenChildrenValid() -> Bool { false }
    public func canDirectlyMultiply() -> Bool { hasBrackets }

    /// Optimises the LinearGroup's representation. It returns a modified version of this instance, keeping the ID the same.
    /// This function is to be called every time the equation is modified, and has no effects on the equation's appearance.
    public func optimised() -> any EquationToken {
        var contentsCopy = contents

        // optimise everything
        for index in 0..<contentsCopy.count {
            contentsCopy[index] = contentsCopy[index].groupRepresentation?.optimised() ?? contentsCopy[index]
        }

        // For some of these, we iterate over the array backwards, to prevent access errors

        // break out non-bracket LinearGroups
        for index in (0..<contentsCopy.count).reversed() {
            if let linearGroup = contentsCopy[index] as? LinearGroup {
                if !linearGroup.hasBrackets {
                    contentsCopy.remove(at: index)
                    guard let linearOptimised = linearGroup.optimised() as? LinearGroup else {
                        continue
                    }
                    contentsCopy.insert(contentsOf: linearOptimised.contents, at: index)
                }
            }
        }

        // Turn consecutive number tokens into a single token
        var lastNumberToken: Int? = nil
        for index in (0..<contentsCopy.count).reversed() {
            if let number = contentsCopy[index] as? NumberToken {
                if let lastNumberToken {
                    // get the last token, and integrate it into this token. Simple string concat.
                    contentsCopy.remove(at: index+1)

                    let lastNumberTokenMagnitude = Int(log(Double(lastNumberToken))/log(10))

                    let newDigit = lastNumberToken + number.digit * Int(pow(10, Double(1 + lastNumberTokenMagnitude)))

                    contentsCopy[index] = NumberToken(
                        id: contentsCopy[index].id,
                        digit: newDigit
                    )
                }
                lastNumberToken = number.digit
            } else {
                lastNumberToken = nil
            }
        }

        return LinearGroup(id: self.id, contents: contentsCopy, hasBrackets: self.hasBrackets)
    }

    public func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool {
        switch insertionLocation {
        case .leading, .trailing:
            return hasBrackets
        case .within:
            return contents.isEmpty
        }
    }

    public func inserting(
        token: any EquationToken,
        at insertionLocation: InsertionPoint.InsertionLocation,
        relativeToID referenceTokenID: UUID!
    ) -> any EquationToken {
        var mutableSelf = self
        guard insertionLocation != .within else {
            // if its within, its only valid if we have no children
            guard self.contents.isEmpty else {
                fatalError("Tried to assign `.within` of a non-empty LinearGroup")
            }
            mutableSelf.contents = [token]
            return mutableSelf
        }

        guard let referenceTokenID, let refIndex = contents.firstIndex(where: { $0.id == referenceTokenID }) else {
            fatalError("Tried to insert relative to a non-child of LinearGroup")
        }

        // If its trailing, add one to the index. Else, its leading, and we use the index itself
        mutableSelf.contents.insert(token, at: refIndex + (insertionLocation == .trailing ? 1 : 0))
        return mutableSelf
    }

    public func removing(childID: UUID) -> (any EquationToken)? {
        var mutableSelf = self
        mutableSelf.contents.removeAll(where: { $0.id == childID })
        return mutableSelf
    }

    public func replacing(
        originalTokenID: UUID,
        with newToken: any EquationToken
    ) -> any EquationToken {
        var mutableSelf = self
        guard let replacementIndex = contents.firstIndex(where: { $0.id == originalTokenID }) else {
            fatalError("Tried to replace a token that is not a child of LinearGroup")
        }
        mutableSelf.contents[replacementIndex] = newToken
        return mutableSelf
    }

    public func child(with id: UUID) -> (any EquationToken)? {
        return contents.first(where: { $0.id == id })
    }

    public func child(leftOf id: UUID) -> (any EquationToken)? {
        guard let index = contents.firstIndex(where: { $0.id == id }), index > 0 else { return nil }
        return contents[index-1]
    }

    public func child(rightOf id: UUID) -> (any EquationToken)? {
        guard let index = contents.firstIndex(where: { $0.id == id }), index < contents.count-1 else { return nil }
        return contents[index+1]
    }

    public func firstChild() -> (any EquationToken)? {
        contents.first
    }

    public func lastChild() -> (any EquationToken)? {
        contents.last
    }
}
