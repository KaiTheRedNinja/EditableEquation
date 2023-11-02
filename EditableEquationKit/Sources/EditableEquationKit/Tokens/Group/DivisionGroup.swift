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

    public func inserting(token: any EquationToken, at insertionPoint: InsertionPoint) -> any EquationToken {
        guard insertionPoint.treeLocation.pathComponents.count >= 2,
              let firstItem = insertionPoint.treeLocation.pathComponents.first
        else {
            print("Not enough components to insert")
            return self
        }

        let nextInsertionPoint = InsertionPoint(
            treeLocation: insertionPoint.treeLocation.removingFirstParent(),
            insertionLocation: insertionPoint.insertionLocation
        )

        if numerator.id == firstItem, 
            let newNumerator = numerator.inserting(
                token: token,
                at: nextInsertionPoint
            ) as? LinearGroup {
            return DivisionGroup(
                id: self.id,
                numerator: newNumerator,
                denominator: denominator
            )
        }

        if denominator.id == firstItem,
            let newDenominator = denominator.inserting(
              token: token,
              at: nextInsertionPoint
            ) as? LinearGroup {
            return DivisionGroup(
                id: self.id,
                numerator: numerator,
                denominator: newDenominator
            )
        }

        print("Is not in numerator or denominator")
        return self
    }

    public func removing(at location: TokenTreeLocation) -> any EquationToken {
        guard location.pathComponents.count >= 2,
              let firstItem = location.pathComponents.first
        else { return self }

        let nextLocation = location.removingFirstParent()

        if numerator.id == firstItem,
            let newNumerator = numerator.removing(at: nextLocation) as? LinearGroup {
            return DivisionGroup(
                id: self.id,
                numerator: newNumerator,
                denominator: denominator
            )
        }

        if denominator.id == firstItem,
            let newDenominator = denominator.removing(at: nextLocation) as? LinearGroup {
            return DivisionGroup(
                id: self.id,
                numerator: numerator,
                denominator: newDenominator
            )
        }

        return self
    }

    public func replacing(token: any EquationToken, at location: TokenTreeLocation) -> any EquationToken {
        guard let firstItem = location.pathComponents.first else { return self }

        let nextLocation = location.removingFirstParent()

        if location.pathComponents.count >= 2 {
            if numerator.id == firstItem,
               let newNumerator = numerator.replacing(token: token, at: nextLocation) as? LinearGroup {
                return DivisionGroup(
                    id: self.id,
                    numerator: newNumerator,
                    denominator: denominator
                )
            }

            if denominator.id == firstItem,
               let newDenominator = denominator.replacing(token: token, at: nextLocation) as? LinearGroup {
                return DivisionGroup(
                    id: self.id,
                    numerator: numerator,
                    denominator: newDenominator
                )
            }
        } else {
            guard let linearGroup = token as? LinearGroup else { return self }
            if numerator.id == firstItem {
                return DivisionGroup(
                    id: self.id,
                    numerator: linearGroup,
                    denominator: denominator
                )
            } else if denominator.id == firstItem {
                return DivisionGroup(
                    id: self.id,
                    numerator: numerator,
                    denominator: linearGroup
                )
            }
        }

        return self
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
