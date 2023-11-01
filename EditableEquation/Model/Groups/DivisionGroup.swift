//
//  DivisionGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct DivisionGroup: GroupEquationToken {
    var id: UUID = .init()
    private(set) var name: String = "DivisionGroup"

    var numerator: LinearGroup
    var denominator: LinearGroup

    init(id: UUID = .init(), numerator: [any SingleEquationToken], denominator: [any SingleEquationToken]) {
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
    func canPrecede(_ other: (any SingleEquationToken)?) -> Bool { true }
    func canSucceed(_ other: (any SingleEquationToken)?) -> Bool { true }
    func validWhenChildrenValid() -> Bool { true }
    func canDirectlyMultiply() -> Bool { false }

    func optimised() -> any SingleEquationToken {
        guard let numeratorOptimised = numerator.optimised() as? LinearGroup,
              let denominatorOptimised = numerator.optimised() as? LinearGroup
        else { return self }

        return DivisionGroup(
            id: self.id,
            numerator: numeratorOptimised,
            denominator: denominatorOptimised
        )
    }

    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool {
        // only `within` is poorly defined, the rest are fine
        return insertionLocation != .within
    }

    func inserting(token: any SingleEquationToken, at insertionPoint: InsertionPoint) -> any SingleEquationToken {
        guard insertionPoint.treeLocation.pathComponents.count >= 2,
              let firstItem = insertionPoint.treeLocation.pathComponents.first
        else {
            print("Not enough components to insert")
            return self
        }

        let nextInsertionPoint = InsertionPoint(
            treeLocation: insertionPoint.treeLocation.removingFirstPathComponent(),
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

    func removing(at location: TokenTreeLocation) -> any SingleEquationToken {
        guard location.pathComponents.count >= 2,
              let firstItem = location.pathComponents.first
        else { return self }

        let nextLocation = location.removingFirstPathComponent()

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

    func replacing(token: any SingleEquationToken, at location: TokenTreeLocation) -> any SingleEquationToken {
        guard let firstItem = location.pathComponents.first else { return self }

        let nextLocation = location.removingFirstPathComponent()

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

    func child(with id: UUID) -> (any SingleEquationToken)? {
        if numerator.id == id {
            return numerator
        } else if denominator.id == id {
            return denominator
        }

        return nil
    }

    func child(leftOf id: UUID) -> (any SingleEquationToken)? {
        if denominator.id == id {
            return numerator
        }

        return nil
    }

    func child(rightOf id: UUID) -> (any SingleEquationToken)? {
        if numerator.id == id {
            return denominator
        }

        return nil
    }

    func firstChild() -> (any SingleEquationToken)? {
        numerator
    }

    func lastChild() -> (any SingleEquationToken)? {
        denominator
    }
}
