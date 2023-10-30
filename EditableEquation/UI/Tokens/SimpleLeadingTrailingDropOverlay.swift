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
            if manager.insertionPoint?.treeLocation == treeLocation &&
                manager.insertionPoint?.insertionLocation == .leading {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 3)
            }
            Color.blue.opacity(0.0001)
                .dropDestination(for: Data.self) { items, location in
                    for item in items {
                        withAnimation {
                            manager.manage(
                                data: item,
                                droppedAt: .init(treeLocation: treeLocation, insertionLocation: .leading)
                            )
                        }
                    }
                    return true
                } isTargeted: { isTargeted in
                    print("Is targeted: \(isTargeted)")
                    if isTargeted {
                        manager.insertionPoint = .init(treeLocation: treeLocation, insertionLocation: .leading)
                    } else {
                        manager.insertionPoint = nil
                    }
                }
                .onTapGesture {
                    manager.insertionPoint = .init(treeLocation: treeLocation, insertionLocation: .leading)
                }

            Color.red.opacity(0.0001)
                .dropDestination(for: Data.self) { items, location in
                    for item in items {
                        withAnimation {
                            manager.manage(
                                data: item,
                                droppedAt: .init(treeLocation: treeLocation, insertionLocation: .trailing)
                            )
                        }
                    }
                    return true
                } isTargeted: { isTargeted in
                    print("Is targeted: \(isTargeted)")
                    if isTargeted {
                        manager.insertionPoint = .init(treeLocation: treeLocation, insertionLocation: .trailing)
                    } else {
                        manager.insertionPoint = nil
                    }
                }
                .onTapGesture {
                    manager.insertionPoint = .init(treeLocation: treeLocation, insertionLocation: .trailing)
                }
            if manager.insertionPoint?.treeLocation == treeLocation &&
                manager.insertionPoint?.insertionLocation == .trailing {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 3)
            }
        }
    }
}
