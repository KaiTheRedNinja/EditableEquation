//
//  GeneralTokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

/// A view that takes in `any EquationToken` and shows the correct view for it
public struct GeneralTokenView: View {
    public var token: any EquationToken
    public var treeLocation: TokenTreeLocation

    public var namespace: Namespace.ID

    public init(token: any EquationToken, treeLocation: TokenTreeLocation, namespace: Namespace.ID) {
        self.token = token
        self.treeLocation = treeLocation
        self.namespace = namespace
    }

    public var body: some View {
        TokenViewProvider
            .getView(for: token, treeLocation: treeLocation, namespace: namespace)
            .tokenLocationDragSource(for: treeLocation)
    }
}
