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

    @EnvironmentObject var manager: EquationManager

    var namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            LinearGroupView(
                linearGroup: divisionGroup.numerator,
                treeLocation: treeLocation.appending(child: divisionGroup.numerator.id),
                namespace: namespace
            )
            .overlay(alignment: .bottom) {
                Color.black.frame(height: 2)
                    .offset(y: 1)
                    .onTapGesture {
                        convertToLinearDivision()
                    }
            }
            LinearGroupView(
                linearGroup: divisionGroup.denominator,
                treeLocation: treeLocation.appending(child: divisionGroup.denominator.id),
                namespace: namespace
            )
            .overlay(alignment: .top) {
                Color.black.frame(height: 2)
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
        print("CONVERTING")
        var leadingGroup = divisionGroup.numerator

        leadingGroup.hasBrackets = leadingGroup.contents.count > 1

        var trailingGroup = divisionGroup.denominator

        trailingGroup.hasBrackets = trailingGroup.contents.count > 1

        let newLinearGroup = LinearGroup(contents: [
            leadingGroup,
            LinearOperationToken(operation: .divide),
            trailingGroup
        ])

        print("REPLACING")

        withAnimation {
            manager.replace(token: newLinearGroup, at: treeLocation)
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
