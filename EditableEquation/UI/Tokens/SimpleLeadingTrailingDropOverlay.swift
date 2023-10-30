//
//  SimpleLeadingTrailingDropOverlay.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI

struct SimpleLeadingTrailingDropOverlay: View {
    var treeLocation: TokenTreeLocation

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        HStack(spacing: 0) {
            SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading))
            SimpleDropOverlay(insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing))
        }
    }
}

struct SimpleDropOverlay: View {
    var insertionPoint: InsertionPoint

    @EnvironmentObject var manager: EquationManager

    var body: some View {
        Color.blue.opacity(0.0001)
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
                print("Is targeted: \(isTargeted)")
                if isTargeted {
                    manager.insertionPoint = insertionPoint
                } else {
                    manager.insertionPoint = nil
                }
            }
            .onTapGesture {
                manager.insertionPoint = insertionPoint
            }
            .background(alignment: cursorAlignment) {
                if manager.insertionPoint == insertionPoint {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.accentColor)
                        .frame(width: 3)
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
