//
//  DivisionGroup.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct DivisionGroup: GroupEquationToken {
    var id: UUID = .init()

    var numerator: LinearGroup
    var denominator: LinearGroup

    init(id: UUID = .init(), numerator: [EquationToken], denominator: [EquationToken]) {
        self.id = id
        self.numerator = .init(contents: numerator, hasBrackets: false)
        self.denominator = .init(contents: denominator, hasBrackets: false)
    }

    private init(id: UUID = .init(), numerator: LinearGroup, denominator: LinearGroup) {
        self.id = id
        self.numerator = numerator
        self.denominator = denominator
    }

    func validate() -> Bool {
        return numerator.validate() && denominator.validate()
    }

    func optimised() -> DivisionGroup {
        return .init(
            id: self.id,
            numerator: numerator.optimised(),
            denominator: denominator.optimised()
        )
    }

    func canInsert(at insertionLocation: InsertionPoint.InsertionLocation) -> Bool {
        // only `within` is poorly defined, the rest are fine
        return insertionLocation != .within
    }

    func inserting(token: EquationToken, at insertionPoint: InsertionPoint) -> DivisionGroup {
        print("INSERTING")
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

        if numerator.id == firstItem {
            return .init(
                id: self.id,
                numerator: numerator.inserting(
                    token: token, 
                    at: nextInsertionPoint
                ),
                denominator: denominator
            )
        } else if denominator.id == firstItem {
            return .init(
                id: self.id,
                numerator: numerator,
                denominator: denominator.inserting(
                    token: token,
                    at: nextInsertionPoint
                )
            )
        }

        print("Is not in numerator or denominator")
        return self
    }

    func removing(at location: TokenTreeLocation) -> DivisionGroup {
        guard location.pathComponents.count >= 2,
              let firstItem = location.pathComponents.first
        else { return self }

        let nextLocation = location.removingFirstPathComponent()

        if numerator.id == firstItem {
            return .init(
                id: self.id,
                numerator: numerator.removing(at: nextLocation),
                denominator: denominator
            )
        } else if denominator.id == firstItem {
            return .init(
                id: self.id,
                numerator: numerator,
                denominator: denominator.removing(at: nextLocation)
            )
        }

        return self
    }

    func child(with id: UUID) -> EquationToken? {
        if numerator.id == id {
            return .linearGroup(numerator)
        } else if denominator.id == id {
            return .linearGroup(denominator)
        }

        return nil
    }

    func child(leftOf id: UUID) -> EquationToken? {
        if denominator.id == id {
            return .linearGroup(numerator)
        }

        return nil
    }

    func child(rightOf id: UUID) -> EquationToken? {
        if numerator.id == id {
            return .linearGroup(denominator)
        }

        return nil
    }

    func firstChild() -> EquationToken? {
        .linearGroup(numerator)
    }

    func lastChild() -> EquationToken? {
        .linearGroup(denominator)
    }
}
