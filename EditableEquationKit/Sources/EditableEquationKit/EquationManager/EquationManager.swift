//
//  EquationManager.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 29/10/23.
//

import Foundation
import EditableEquationCore

public class EquationManager: ObservableObject {
    @Published public internal(set) var root: LinearGroup
    @Published public var insertionPoint: InsertionPoint?

    @Published public internal(set) var error: InsertionPoint?

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
