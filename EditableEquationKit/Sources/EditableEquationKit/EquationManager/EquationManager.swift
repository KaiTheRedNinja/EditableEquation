//
//  EquationManager.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 29/10/23.
//

import Foundation
import EditableEquationCore

/// A class that manages an Equation
public class EquationManager: ObservableObject {
    /// The root `LinearGroup` of the equation
    @Published public internal(set) var root: LinearGroup
    /// The point at which the cursor is positioned
    @Published public var insertionPoint: InsertionPoint?

    /// The location of any error
    @Published public internal(set) var error: EquationError?

    public init(root: LinearGroup) {
        self.root = (root.optimised() as? LinearGroup) ?? root

        if let leadingItem = root.firstChild() {
            insertionPoint = .init(
                treeLocation: .init(pathComponents: [leadingItem.id]),
                insertionLocation: .leading
            )
        } else {
            insertionPoint = .init(
                treeLocation: .init(pathComponents: []),
                insertionLocation: .within
            )
        }

        updateErrors()

        // register all the types for use
        EquationTokenCoding.register(type: NumberToken.self, for: "Number")
        EquationTokenCoding.register(type: LinearOperationToken.self, for: "LinearOperation")
        EquationTokenCoding.register(type: LinearGroup.self, for: "LinearGroup")
        EquationTokenCoding.register(type: DivisionGroup.self, for: "DivisionGroup")
    }
}
