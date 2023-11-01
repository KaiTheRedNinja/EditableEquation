//
//  DivisionGroupView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

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
                NumberToken(digit: 69),
                LinearOperationToken(operation: .minus),
                NumberToken(digit: 420)
            ],
            denominator: [
                LinearGroup(
                    contents: [
                        NumberToken(digit: 4),
                        LinearOperationToken(operation: .minus),
                        NumberToken(digit: 9)
                    ],
                    hasBrackets: true
                ),
                LinearOperationToken(operation: .times),
                LinearGroup(
                    contents: [],
                    hasBrackets: true
                ),
                LinearOperationToken(operation: .times),
                NumberToken(digit: 5),
                LinearOperationToken(operation: .plus),
                NumberToken(digit: 10)
            ]),
        treeLocation: .init(pathComponents: []),
        namespace: Namespace().wrappedValue
    )
}
