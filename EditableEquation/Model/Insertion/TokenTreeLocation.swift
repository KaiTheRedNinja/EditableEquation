//
//  TokenTreeLocation.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import Foundation

struct TokenTreeLocation: Codable, Hashable {
    private(set) var pathComponents: [UUID]

    func adding(pathComponent: UUID) -> TokenTreeLocation {
        var mutableSelf = self
        mutableSelf.pathComponents.append(pathComponent)
        return mutableSelf
    }

    func removingLastPathComponent() -> TokenTreeLocation {
        var mutableSelf = self
        _ = mutableSelf.pathComponents.removeLast()
        return mutableSelf
    }

    func removingFirstPathComponent() -> TokenTreeLocation {
        var mutableSelf = self
        _ = mutableSelf.pathComponents.removeFirst()
        return mutableSelf
    }
}
