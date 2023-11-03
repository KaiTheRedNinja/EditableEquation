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
            SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading), namespace: namespace)
            SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing), namespace: namespace)
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
            .dropDestination(for: Data.self) { items, location in
                for item in items {
                    withAnimation {
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
                manager.insertionPoint = insertionPoint
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
    public func tokenDragSource<T: EquationToken>(for token: T) -> some View {
        self
            .draggable({ () -> Data in
                return (try? JSONEncoder().encode(token)) ?? .init()
            }())
    }

    public func tokenDragSource<T: EquationToken, C: View>(for token: T, preview: () -> C) -> some View {
        self
            .draggable({ () -> Data in
                return (try? JSONEncoder().encode(token)) ?? .init()
            }(), preview: preview)
    }
}
