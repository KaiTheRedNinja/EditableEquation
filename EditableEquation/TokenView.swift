//
//  TokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct TokenView: View {
    var token: EquationToken

    var body: some View {
        switch token {
        case .number(let numberToken):
            NumberTokenView(number: numberToken)
        case .linearOperation(let linearOperationToken):
            LinearOperationView(linearOperation: linearOperationToken)
        case .linearGroup(let linearGroup):
            LinearGroupView(linearGroup: linearGroup)
        }
    }
}

struct NumberTokenView: View {
    var number: NumberToken

    @State var dropHighlight: InsertionPoint.InsertionLocation?

    var body: some View {
        Text("\(number.digit)")
            .padding(.horizontal, 3)
            .overlay {
                HStack(spacing: 0) {
                    if dropHighlight == .leading {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor)
                            .frame(width: 3)
                    }
                    Color.blue.opacity(0.0001)
                        .dropDestination(for: String.self) { items, location in
                            print("Dropped \(items) on \(location)")
                            return false
                        } isTargeted: { isTargeted in
                            print("Is targeted: \(isTargeted)")
                            dropHighlight = isTargeted ? .leading : nil
                        }

                    Color.red.opacity(0.0001)
                        .dropDestination(for: String.self) { items, location in
                            print("Dropped \(items) on \(location)")
                            return false
                        } isTargeted: { isTargeted in
                            print("Is targeted: \(isTargeted)")
                            dropHighlight = isTargeted ? .trailing : nil
                        }
                    if dropHighlight == .trailing {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor)
                            .frame(width: 3)
                    }
                }
            }
    }
}

struct LinearOperationView: View {
    var linearOperation: LinearOperationToken

    @State var dropHighlight: InsertionPoint.InsertionLocation?

    var body: some View {
        Text(operationText)
            .padding(.horizontal, 3)
            .overlay {
                HStack(spacing: 0) {
                    if dropHighlight == .leading {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor)
                            .frame(width: 3)
                    }
                    Color.blue.opacity(0.0001)
                        .dropDestination(for: String.self) { items, location in
                            print("Dropped \(items) on \(location)")
                            return false
                        } isTargeted: { isTargeted in
                            print("Is targeted: \(isTargeted)")
                            dropHighlight = isTargeted ? .leading : nil
                        }

                    Color.red.opacity(0.0001)
                        .dropDestination(for: String.self) { items, location in
                            print("Dropped \(items) on \(location)")
                            return false
                        } isTargeted: { isTargeted in
                            print("Is targeted: \(isTargeted)")
                            dropHighlight = isTargeted ? .trailing : nil
                        }
                    if dropHighlight == .trailing {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor)
                            .frame(width: 3)
                    }
                }
            }
    }

    var operationText: String {
        switch linearOperation.operation {
        case .plus:
            "+"
        case .minus:
            "-"
        case .times:
            "×"
        case .divide:
            "÷"
        }
    }
}

struct LinearGroupView: View {
    var linearGroup: LinearGroup

    var body: some View {
        HStack(spacing: 0) {
            ForEach(linearGroup.contents) { content in
                TokenView(token: content)
            }
        }
    }
}

#Preview {
    VStack {
        TokenView(
            token: .linearGroup(LinearGroup(contents: [
                .number(.init(digit: 69)),
                .linearOperation(.init(operation: .minus)),
                .number(.init(digit: 420)),
                .linearOperation(.init(operation: .divide)),
                .number(.init(digit: 12))
            ]))
        )
        .font(.title2)

        Spacer().frame(height: 100)

        Text("HI")
            .draggable("this is fun")
    }
}
