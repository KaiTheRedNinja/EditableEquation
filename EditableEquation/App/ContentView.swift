//
//  ContentView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI
import EditableEquationKit
import EditableEquationUI
import Rationals

let defaultRoot = LinearGroup(
    contents: [
        NumberToken(digit: 69),
        LinearOperationToken(operation: .minus),
        NumberToken(digit: 420),
        LinearOperationToken(operation: .divide),
        LinearGroup(
            contents: [
                DivisionGroup(
                    numerator: [
                        NumberToken(digit: 4),
                        LinearOperationToken(operation: .times),
                        NumberToken(digit: 9)
                    ],
                    denominator: [
                        NumberToken(digit: 5)
                    ]
                ),
                LinearOperationToken(operation: .times),
                LinearGroup(
                    contents: [
                        NumberToken(digit: 8)
                    ],
                    hasBrackets: true
                ),
                LinearOperationToken(operation: .times),
                NumberToken(digit: 5),
                LinearOperationToken(operation: .plus),
                NumberToken(digit: 10)
            ],
            hasBrackets: true
        ),
        LinearOperationToken(operation: .times),
        NumberToken(digit: 12)
    ]
)

struct ContentView: View {
    var body: some View {
        MainView(initialRoot: defaultRoot)
    }
}

#Preview {
    ContentView()
}
