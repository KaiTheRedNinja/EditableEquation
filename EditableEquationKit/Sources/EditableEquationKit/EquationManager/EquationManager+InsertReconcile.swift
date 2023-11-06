//
//  EquationManager+InsertReconcile.swift
//
//
//  Created by Kai Quan Tay on 4/11/23.
//

import Foundation
import EditableEquationCore

extension EquationManager {
    internal func reconcile(
        insertionPoint: InsertionPoint,
        originalRoot: any EquationToken,
        newRoot: any EquationToken
    ) -> InsertionPoint? {
        guard let originalRoot = originalRoot.groupRepresentation,
              let newRoot = newRoot.groupRepresentation,
              exists(location: insertionPoint.treeLocation, in: originalRoot)
        else { return nil }

        var insertionPoint = insertionPoint

        while !insertionPoint.treeLocation.pathComponents.isEmpty {
            // if it exists in new root, nothing needs to be done
            guard !exists(location: insertionPoint.treeLocation, in: newRoot)
            else {
                return insertionPoint
            }

            // if it doesn't, try to get the alternative representation of the insertion point, and check if that exists
            let altPoint = alternativeRepresentation(for: insertionPoint, in: originalRoot)
            if let altPoint, exists(location: altPoint.treeLocation, in: newRoot) {
                // if it exists, return the alt point
                return altPoint
            }

            // if that doesn't, try and recursive search for the reference token
            let refTokenID = insertionPoint.treeLocation.pathComponents.last!
            if let newPath = findPath(for: refTokenID, in: newRoot) {
                return InsertionPoint(
                    treeLocation: newPath,
                    insertionLocation: insertionPoint.insertionLocation
                )
            }

            // if that still doesn't, try and recursive search for the alternative representation
            if let altPoint, let altTokenID = altPoint.treeLocation.pathComponents.last {
                if let newPath = findPath(for: altTokenID, in: newRoot) {
                    return InsertionPoint(
                        treeLocation: newPath,
                        insertionLocation: altPoint.insertionLocation
                    )
                }
            }

            // remove children from insertionPoint until it works, or we completely empty the insertion point
            insertionPoint.treeLocation = insertionPoint.treeLocation.removingLastChild()
        }

        return nil
    }

    private func exists(location: TokenTreeLocation, in rootToken: any GroupEquationToken) -> Bool {
        // if the location is empty, it refers to the root token itself, in which case, it exists.
        guard !location.pathComponents.isEmpty else { return true }

        var currentToken: any GroupEquationToken = rootToken

        for item in location.removingLastChild().pathComponents {
            guard let newCurrent = currentToken.child(with: item)?.groupRepresentation else { return false }
            currentToken = newCurrent
        }

        return currentToken.child(with: location.pathComponents.last!) != nil
    }

    private func alternativeRepresentation(
        for insertionPoint: InsertionPoint,
        in rootToken: any GroupEquationToken
    ) -> InsertionPoint? {
        // if its a .within or the path is empty, there is no alternative form
        guard insertionPoint.insertionLocation != .within,
              !insertionPoint.treeLocation.pathComponents.isEmpty
        else { return nil }

        // get the parent
        var currentToken: any GroupEquationToken = rootToken

        for item in insertionPoint.treeLocation.removingLastChild().pathComponents {
            // if at any point we can't proceed, the token doesn't exist in the first place. Return nil.
            guard let newCurrent = currentToken.child(with: item)?.groupRepresentation else { return nil }
            currentToken = newCurrent
        }

        let lastComponent = insertionPoint.treeLocation.pathComponents.last!
        let newChildId: UUID?
        let newPosition: InsertionPoint.InsertionLocation
        switch insertionPoint.insertionLocation {
        case .leading:
            newChildId = currentToken.child(leftOf: lastComponent)?.id
            newPosition = .trailing
        case .trailing:
            newChildId = currentToken.child(rightOf: lastComponent)?.id
            newPosition = .leading
        default: fatalError()
        }

        // if newChildId is nil, its either on the very left or very right and theres no other tokens
        guard let newChildId else { return nil }
        return InsertionPoint(
            treeLocation: insertionPoint.treeLocation.removingLastChild().appending(child: newChildId),
            insertionLocation: newPosition
        )
    }

    internal func findPath(
        for tokenID: UUID,
        in rootToken: any GroupEquationToken
    ) -> TokenTreeLocation? {
        // if rootToken is tokenID, return an empty location
        guard rootToken.id != tokenID else { return .init(pathComponents: []) }

        // recursively search for the token using depth-first-search
        var currentPath: [any GroupEquationToken] = [rootToken]
        while true {
            // this will be turned to true if we should `continue` instead of remove an element
            var continueFlag: Bool = false

            // try and access the children of `currentPath`
            var child = currentPath.last?.firstChild()
            while let validChild = child {
                // check if the child is what we're looking for
                if validChild.id == tokenID {
                    return .init(pathComponents: currentPath.dropFirst().map({ $0.id }) + [validChild.id])
                }

                // if not, see if the child is a group token. If it is, add it to `currentPath` and go again
                if let validChild = validChild as? any GroupEquationToken {
                    currentPath.append(validChild)
                    continueFlag = true
                    break
                }

                // try and get the next child
                child = currentPath.last?.child(rightOf: validChild.id)
            }

            if continueFlag == true {
                continue
            }

            // if we reach the end of `currentPath` without finding the token, try accessing the siblings to 
            // the right of the current path.
            // if the siblings don't contain the token, we remove an element from `currentPath` and try again
            // if we are left with just 1 item, it isn't possible and the token doesn't exist

            while currentPath.count >= 2 {
                let pathCount = currentPath.count

                // access the siblings
                var nextChild = currentPath[pathCount-2].child(rightOf: currentPath[pathCount-1].id)
                while let validNextChild = nextChild {
                    // check if the child is what we're looking for
                    if validNextChild.id == tokenID {
                        return .init(
                            pathComponents: currentPath.dropFirst().dropLast().map({ $0.id }) + [validNextChild.id]
                        )
                    }

                    // if not, see if the child is a group token. If it is, replace it as 
                    // the last item of `currentPath` and break out
                    if let validChild = validNextChild as? any GroupEquationToken {
                        currentPath[pathCount-1] = validChild
                        continueFlag = true
                        break
                    }

                    // try and get the next child
                    nextChild = currentPath.last?.child(rightOf: validNextChild.id)
                }

                if continueFlag == true {
                    break
                }

                // remove an element and keep on going
                currentPath = currentPath.dropLast()
            }

            if continueFlag == true {
                continue
            }

            // if we went through it all and didn't find anything, just return nil
            return nil
        }
    }
}
