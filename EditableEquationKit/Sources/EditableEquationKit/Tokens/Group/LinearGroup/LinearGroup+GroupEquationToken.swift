//
//  LinearGroup+GroupEquationToken.swift
//
//
//  Created by Kai Quan Tay on 4/11/23.
//

import Foundation
import EditableEquationCore

extension LinearGroup: GroupEquationToken {
    public func validWhenChildrenValid() -> Bool { false }
    public func canDirectlyMultiply() -> Bool { hasBrackets }

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
