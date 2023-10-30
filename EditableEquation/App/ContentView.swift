//
//  ContentView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var manager: EquationManager = .init(
        root: LinearGroup(
            contents: [
                .number(.init(digit: 69)),
                .linearOperation(.init(operation: .minus)),
                .number(.init(digit: 420)),
                .linearOperation(.init(operation: .divide)),
                .linearGroup(.init(
                    contents: [
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
                    ],
                    hasBrackets: true
                )),
                .linearOperation(.init(operation: .times)),
                .number(.init(digit: 12))
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
                    let token = EquationToken.number(NumberToken(digit: 42))
                    return (try? JSONEncoder().encode(token)) ?? .init()
                }())
                .onTapGesture {
                    guard let insertionPoint = manager.insertionPoint else { return }
                    withAnimation {
                        manager.insert(token: EquationToken.number(NumberToken(digit: 42)), at: insertionPoint)
                    }
                }

            HStack {
                Button("<") {
                    manager.moveLeft()
                }
                Button(">") {
                    manager.moveRight()
                }
            }

            Text("Is valid: \(manager.root.validate().description)")
        }
    }
}

#Preview {
    ContentView()
}
