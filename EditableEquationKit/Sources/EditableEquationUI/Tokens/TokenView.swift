//
//  TokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

public protocol TokenView: View {
    var treeLocation: TokenTreeLocation { get }
    var namespace: Namespace.ID { get }
}

/// A view that takes in `any EquationToken` and shows the correct view for it
public struct GeneralTokenView: TokenView {
    public var token: any EquationToken
    public var treeLocation: TokenTreeLocation

    public var namespace: Namespace.ID

    public init(token: any EquationToken, treeLocation: TokenTreeLocation, namespace: Namespace.ID) {
        self.token = token
        self.treeLocation = treeLocation
        self.namespace = namespace
    }

    public var body: some View {
        Group {
            if let numberToken = token as? NumberToken {
                NumberTokenView(
                    number: numberToken,
                    treeLocation: treeLocation,
                    namespace: namespace
                )
                .matchedGeometryEffect(id: token.id, in: namespace)
            }
            if let linearOperationToken = token as? LinearOperationToken {
                LinearOperationView(
                    linearOperation: linearOperationToken,
                    treeLocation: treeLocation,
                    namespace: namespace
                )
                .matchedGeometryEffect(id: token.id, in: namespace)
            }
            if let linearGroup = token as? LinearGroup {
                LinearGroupView(
                    linearGroup: linearGroup,
                    treeLocation: treeLocation,
                    namespace: namespace
                )
                .matchedGeometryEffect(id: token.id, in: namespace)
            }
            if let divisionGroup = token as? DivisionGroup {
                DivisionGroupView(
                    divisionGroup: divisionGroup,
                    treeLocation: treeLocation,
                    namespace: namespace
                )
                .matchedGeometryEffect(id: token.id, in: namespace)
            }
        }
        .tokenLocationDragSource(for: treeLocation)
    }
}
