//
//  ContentView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI
import EditableEquationKit
import EditableEquationUI

struct ContentView: View {
    @ObservedObject var manager: EquationManager = .init(
        root: LinearGroup(
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
                                LinearOperationToken(operation: .minus),
                                NumberToken(digit: 9)
                            ],
                            denominator: [
                                NumberToken(digit: 5)
                            ]
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
                    ],
                    hasBrackets: true
                ),
                LinearOperationToken(operation: .times),
                NumberToken(digit: 12)
            ]
        )
    )

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                EquationView(
                    manager: manager
                )
                .font(.title2)
            }

            Spacer().frame(height: 100)

            Text("42")
                .draggable({ () -> Data in
                    let token = NumberToken(digit: 42)
                    return (try? JSONEncoder().encode(token)) ?? .init()
                }())
                .onTapGesture {
                    guard let insertionPoint = manager.insertionPoint else { return }
                    withAnimation {
                        manager.insert(token: NumberToken(digit: 42), at: insertionPoint)
                    }
                }

            HStack {
                Button("<") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        manager.moveLeft()
                    }
                }
                Button("-") {
                    withAnimation {
                        manager.backspace()
                    }
                }
                Button(">") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        manager.moveRight()
                    }
                }
            }

            if let error = manager.error?.error.description {
                Text("ERROR: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
