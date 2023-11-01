//
//  TokenTreeLocation.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

public struct TokenTreeLocation: Codable, Hashable {
    public private(set) var pathComponents: [UUID]

    public init(pathComponents: [UUID]) {
        self.pathComponents = pathComponents
    }

    public func adding(pathComponent: UUID) -> TokenTreeLocation {
        var mutableSelf = self
        mutableSelf.pathComponents.append(pathComponent)
        return mutableSelf
    }

    public func removingLastPathComponent() -> TokenTreeLocation {
        guard !pathComponents.isEmpty else { return self }
        var mutableSelf = self
        _ = mutableSelf.pathComponents.removeLast()
        return mutableSelf
    }

    public func removingFirstPathComponent() -> TokenTreeLocation {
        guard !pathComponents.isEmpty else { return self }
        var mutableSelf = self
        _ = mutableSelf.pathComponents.removeFirst()
        return mutableSelf
    }
}
