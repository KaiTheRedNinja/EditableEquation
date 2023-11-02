//
//  TokenTreeLocation.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

/// A struct representing the location of a token within a token tree
public struct TokenTreeLocation: Codable, Hashable {
    /// The path to the token
    public private(set) var pathComponents: [UUID]

    public init(pathComponents: [UUID]) {
        self.pathComponents = pathComponents
    }

    public func appending(child: UUID) -> TokenTreeLocation {
        var mutableSelf = self
        mutableSelf.pathComponents.append(child)
        return mutableSelf
    }

    public func prepending(parent: UUID) -> TokenTreeLocation {
        var mutableSelf = self
        mutableSelf.pathComponents.insert(parent, at: 0)
        return mutableSelf
    }

    public func removingLastChild() -> TokenTreeLocation {
        guard !pathComponents.isEmpty else { return self }
        var mutableSelf = self
        _ = mutableSelf.pathComponents.removeLast()
        return mutableSelf
    }

    public func removingFirstParent() -> TokenTreeLocation {
        guard !pathComponents.isEmpty else { return self }
        var mutableSelf = self
        _ = mutableSelf.pathComponents.removeFirst()
        return mutableSelf
    }
}
