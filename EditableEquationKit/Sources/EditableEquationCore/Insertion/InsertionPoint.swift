//
//  InsertionPoint.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

public struct InsertionPoint: Hashable {
    /// The item's location within a token tree
    public var treeLocation: TokenTreeLocation
    /// Where the insertion point is, relative to the tree location
    public var insertionLocation: InsertionLocation

    public enum InsertionLocation: Hashable {
        /// The insertion point is positioned before the token
        case leading
        /// The insertion point is positioned after the token
        case trailing
        /// The insertion point is positioned inside the token (only applies for empty group-type tokens)
        case within
    }

    public init(treeLocation: TokenTreeLocation, insertionLocation: InsertionLocation) {
        self.treeLocation = treeLocation
        self.insertionLocation = insertionLocation
    }

    public func prepending(parent: UUID) -> InsertionPoint {
        var mutableSelf = self
        mutableSelf.treeLocation = mutableSelf.treeLocation.prepending(parent: parent)
        return mutableSelf
    }
}

