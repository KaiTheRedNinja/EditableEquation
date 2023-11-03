//
//  DivisionGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation
import EditableEquationCore

/// A group token representing a fraction
public struct DivisionGroup: GroupEquationToken {
    public var id: UUID = .init()
    public private(set) var name: String = "DivisionGroup"

    public var numerator: LinearGroup
    public var denominator: LinearGroup

    public init(id: UUID = .init(), numerator: [any EquationToken], denominator: [any EquationToken]) {
        self.id = id
        self.numerator = .init(contents: numerator, hasBrackets: false)
        self.denominator = .init(contents: denominator, hasBrackets: false)
    }

    private init(id: UUID = .init(), numerator: LinearGroup, denominator: LinearGroup) {
        self.id = id
        self.numerator = numerator
        self.denominator = denominator
    }

    // no special rules apply
    public func canPrecede(_ other: (any EquationToken)?) -> Bool { true }
    public func canSucceed(_ other: (any EquationToken)?) -> Bool { true }
    public func validWhenChildrenValid() -> Bool { true }
    public func canDirectlyMultiply() -> Bool { false }

    public func optimised() -> any EquationToken {
        guard let numeratorOptimised = numerator.optimised() as? LinearGroup,
              let denominatorOptimised = denominator.optimised() as? LinearGroup
        else { return self }

        return DivisionGroup(
            id: self.id,
            numerator: numeratorOptimised,
            denominator: denominatorOptimised
        )
    }

    public func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool {
        // only `within` is poorly defined, the rest are fine
        return insertionLocation != .within
    }

    public func inserting(
        token: any EquationToken,
        at insertionLocation: InsertionPoint.InsertionLocation,
        relativeToID referenceTokenID: UUID!
    ) -> any EquationToken {
        fatalError("Cannot insert in `DivisionGroup`")
    }

    public func removing(childID: UUID) -> (any EquationToken)? {
        if childID == numerator.id || childID == denominator.id {
            return nil
        }

        fatalError("Tried to remove a child that does not belong to DivisionGroup")
    }

    public func replacing(originalTokenID: UUID, with newToken: any EquationToken) -> any EquationToken {
        guard let newTokenLinearGroup = newToken as? LinearGroup else {
            fatalError("Tried to set a non-linergroup as a child of DivisionGroup")
        }

        if originalTokenID == numerator.id {
            return DivisionGroup(
                id: self.id,
                numerator: newTokenLinearGroup,
                denominator: denominator
            )
        }

        if originalTokenID == denominator.id {
            return DivisionGroup(
                id: self.id,
                numerator: numerator,
                denominator: newTokenLinearGroup
            )
        }

        fatalError("Tried to replace a child that does not belong to DivisionGroup")
    }

    public func child(with id: UUID) -> (any EquationToken)? {
        if numerator.id == id {
            return numerator
        } else if denominator.id == id {
            return denominator
        }

        return nil
    }

    public func child(leftOf id: UUID) -> (any EquationToken)? {
        if denominator.id == id {
            return numerator
        }

        return nil
    }

    public func child(rightOf id: UUID) -> (any EquationToken)? {
        if numerator.id == id {
            return denominator
        }

        return nil
    }

    public func firstChild() -> (any EquationToken)? {
        numerator
    }

    public func lastChild() -> (any EquationToken)? {
        denominator
    }
}
