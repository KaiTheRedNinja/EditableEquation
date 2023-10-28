//
//  Insertion.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import Foundation

struct TokenTreeLocation {
    private(set) var pathComponents: [UUID]

    func adding(pathComponent: UUID) -> TokenTreeLocation {
        var mutableSelf = self
        mutableSelf.pathComponents.append(pathComponent)
        return mutableSelf
    }
}

struct InsertionPoint {
    /// The item's location within a token tree
    var treeLocation: TokenTreeLocation
    /// Where the insertion point is, relative to the tree location
    var insertionLocation: InsertionLocation

    enum InsertionLocation {
        /// The insertion point is positioned before the token
        case leading
        /// The insertion point is positioned after the token
        case trailing
        /// The insertion point is positioned inside the token (only applies for empty group-type tokens)
        case within
    }
}
