//
//  InsertionPoint.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct InsertionPoint: Hashable {
    /// The item's location within a token tree
    var treeLocation: TokenTreeLocation
    /// Where the insertion point is, relative to the tree location
    var insertionLocation: InsertionLocation

    enum InsertionLocation: Hashable {
        /// The insertion point is positioned before the token
        case leading
        /// The insertion point is positioned after the token
        case trailing
        /// The insertion point is positioned inside the token (only applies for empty group-type tokens)
        case within
    }
}

