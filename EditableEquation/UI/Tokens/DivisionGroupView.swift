//
//  DivisionGroupView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI

struct DivisionGroupView: TokenView {
    var divisionGroup: DivisionGroup
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            LinearGroupView(
                linearGroup: divisionGroup.numerator,
                treeLocation: treeLocation.adding(pathComponent: divisionGroup.numerator.id),
                namespace: namespace
            )
            .overlay(alignment: .bottom) {
                Color.black.frame(height: 2)
                    .offset(y: 1)
            }
            LinearGroupView(
                linearGroup: divisionGroup.denominator,
                treeLocation: treeLocation.adding(pathComponent: divisionGroup.denominator.id),
                namespace: namespace
            )
            .overlay(alignment: .top) {
                Color.black.frame(height: 2)
                    .offset(y: -1)
            }
        }
        .padding(.horizontal, 2)
        .overlay {
            HStack {
                SimpleDropOverlay(
                    insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .leading),
                    namespace: namespace
                )
                .frame(width: 3)
                Spacer()
                SimpleDropOverlay(
                    insertionPoint: .init(treeLocation: treeLocation, insertionLocation: .trailing),
                    namespace: namespace
                )
                .frame(width: 3)
            }
        }
    }
}

#Preview {
    DivisionGroupView(
        divisionGroup: .init(
            numerator: [
                .number(.init(digit: 69)),
                .linearOperation(.init(operation: .minus)),
                .number(.init(digit: 420)),
            ],
            denominator: [
                .linearGroup(.init(
                    contents: [
                        .number(.init(digit: 4)),
                        .linearOperation(.init(operation: .minus)),
                        .number(.init(digit: 9))
                    ],
                    hasBrackets: true
                )),
                .linearOperation(.init(operation: .times)),
                .linearGroup(.init(
                    contents: [],
                    hasBrackets: true
                )),
                .linearOperation(.init(operation: .times)),
                .number(.init(digit: 5)),
                .linearOperation(.init(operation: .plus)),
                .number(.init(digit: 10))
            ]),
        treeLocation: .init(pathComponents: []),
        namespace: Namespace().wrappedValue
    )
}
