//
//  SimpleLeadingTrailingDropOverlay.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

struct SimpleLeadingTrailingDropOverlay: View {
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        HStack(spacing: 0) {
            SimpleDropOverlay(
                insertionPoint: .init(
                    treeLocation: treeLocation,
                    insertionLocation: .leading
                ),
                namespace: namespace
            )
            SimpleDropOverlay(
                insertionPoint: .init(
                    treeLocation: treeLocation,
                    insertionLocation: .trailing
                ),
                namespace: namespace
            )
        }
    }
}

/// A view intended to be used in overlays that manages:
/// - The drop target
/// - Showing the cursor
/// - Showing errors
struct SimpleDropOverlay: View {
    var insertionPoint: InsertionPoint

    var namespace: Namespace.ID

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        Color.red.opacity(manager.error?.insertionPoint == insertionPoint ? 0.7 : 0.0001)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay(alignment: cursorAlignment) {
                if manager.insertionPoint == insertionPoint {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.accentColor)
                        .frame(width: 3)
                        .matchedGeometryEffect(id: "cursor", in: namespace)
                }
            }
            .dropDestination(for: Data.self) { items, _ in
                for item in items {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        manager.manage(
                            data: item,
                            droppedAt: insertionPoint
                        )
                    }
                }
                return true
            } isTargeted: { isTargeted in
                if isTargeted {
                    withAnimation {
                        manager.insertionPoint = insertionPoint
                    }
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    manager.insertionPoint = insertionPoint
                }
            }
    }

    var cursorAlignment: Alignment {
        switch insertionPoint.insertionLocation {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .within:
            return .center
        }
    }
}

extension View {
    /// Marks the view as draggable for a token
    public func tokenDragSource(for token: any EquationToken) -> some View {
        self
            .draggable({ () -> Data in
                guard let string = try? EquationTokenCoding.encodeSingle(item: token) else { return Data() }
                return string.data(using: .utf8) ?? Data()
            }())
    }

    /// Marks the view as draggable for a token, with a preview
    public func tokenDragSource<C: View>(for token: any EquationToken, preview: () -> C) -> some View {
        self
            .draggable({ () -> Data in
                guard let string = try? EquationTokenCoding.encodeSingle(item: token) else { return Data() }
                return string.data(using: .utf8) ?? Data()
            }(), preview: preview)
    }

    /// Marks the view as draggable for a token location
    public func tokenLocationDragSource(for location: TokenTreeLocation) -> some View {
        self
            .draggable({ () -> Data in
                return (try? JSONEncoder().encode(location)) ?? .init()
            }())
    }

    /// Marks the view as draggable for a token location, with a preview
    public func tokenLocationDragSource<C: View>(for location: TokenTreeLocation, preview: () -> C) -> some View {
        self
            .draggable({ () -> Data in
                return (try? JSONEncoder().encode(location)) ?? .init()
            }(), preview: preview)
    }
}
