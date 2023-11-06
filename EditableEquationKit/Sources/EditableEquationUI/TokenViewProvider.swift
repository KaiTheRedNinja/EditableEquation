//
//  TokenViewProvider.swift
//
//
//  Created by Kai Quan Tay on 6/11/23.
//

import SwiftUI
import EditableEquationCore

public protocol TokenView: View {
    associatedtype Token: EquationToken

    var token: Token { get }
    var treeLocation: TokenTreeLocation { get }
    var namespace: Namespace.ID { get }

    init(token: Token, treeLocation: TokenTreeLocation, namespace: Namespace.ID)
}

/// Manages providing the view for a token
public enum TokenViewProvider {
    /// A dictionary of view factories to their name
    public static var registeredProviders: [
        String: (any EquationToken, TokenTreeLocation, Namespace.ID) -> AnyView?
    ] = [:]

    /// Registers a view factory wtih a name
    public static func register<T: EquationToken, V: View>(
        @ViewBuilder factory: @escaping (T, TokenTreeLocation, Namespace.ID) -> V,
        for key: String
    ) {
        registeredProviders[key] = {
            guard let item = $0 as? T else { return nil }
            return AnyView(factory(item, $1, $2))
        }
    }

    /// Gets the view, returning a wrapped EmptyView by default
    public static func getView(
        for token: any EquationToken,
        treeLocation: TokenTreeLocation,
        namespace: Namespace.ID
    ) -> AnyView {
        if let factory = registeredProviders[token.name],
           let view = factory(token, treeLocation, namespace) {
            return view
        } else {
            return AnyView(EmptyView())
        }
    }
}
