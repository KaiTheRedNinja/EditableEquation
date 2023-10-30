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
            .number(.init(digit: 12))
            ]
        )
    )

    var body: some View {
        VStack {
            EquationView(
                manager: manager
            )
            .font(.title2)

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
        }
    }
}

#Preview {
    ContentView()
}