//
//  ContentView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            EquationView(
                root: LinearGroup(contents: [
                    .number(.init(digit: 69)),
                    .linearOperation(.init(operation: .minus)),
                    .number(.init(digit: 420)),
                    .linearOperation(.init(operation: .divide)),
                    .number(.init(digit: 12))
                ])
            )
            .font(.title2)

            Spacer().frame(height: 100)

            Text("HI")
                .draggable("this is fun")

            Color.gray.frame(width: 100, height: 100)
                .dropDestination(for: String.self) { items, location in
                    print("Dropped \(items) on \(location)")
                    return false
                } isTargeted: { isTargeted in
                    print("Is targeted: \(isTargeted)")
                }
        }
    }
}

#Preview {
    ContentView()
}
