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
    var token: DivisionGroup
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    @EnvironmentObject var manager: EquationManager

    init(token: DivisionGroup, treeLocation: EditableEquationCore.TokenTreeLocation, namespace: Namespace.ID) {
        self.token = token
        self.treeLocation = treeLocation
        self.namespace = namespace
    }

    var body: some View {
        VStack(spacing: 0) {
            LinearGroupView(
                token: token.numerator,
                treeLocation: treeLocation.appending(child: token.numerator.id),
                namespace: namespace
            )
            .overlay(alignment: .bottom) {
                Color.primary.frame(height: 2)
                    .offset(y: 1)
                    .onTapGesture {
                        convertToLinearDivision()
                    }
            }
            LinearGroupView(
                token: token.denominator,
                treeLocation: treeLocation.appending(child: token.denominator.id),
                namespace: namespace
            )
            .overlay(alignment: .top) {
                Color.primary.frame(height: 2)
                    .offset(y: -1)
                    .onTapGesture {
                        convertToLinearDivision()
                    }
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
        .background {
            Color.black.opacity(0.001)
                .onTapGesture {
                    convertToLinearDivision()
                }
        }
    }

    func convertToLinearDivision() {
        var leadingGroup = token.numerator

        leadingGroup.hasBrackets = leadingGroup.contents.count > 1

        var trailingGroup = token.denominator

        trailingGroup.hasBrackets = trailingGroup.contents.count > 1

        let newLinearGroup = LinearGroup(contents: [
            leadingGroup,
            LinearOperationToken(
                id: token.id,
                operation: .divide
            ),
            trailingGroup
        ])

        withAnimation {
            manager.replace(token: newLinearGroup, at: treeLocation)
        }
    }
}

#Preview {
    DivisionGroupView(
        token: .init(
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
