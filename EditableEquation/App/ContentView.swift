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
    )

    @ObservedObject var numberEditor: NumberEditor = .init()

    @State var resultDisplayType: ResultDisplayType = .fraction

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                EquationView(
                    manager: manager,
                    numberEditor: numberEditor
                )
                .font(.title2)
            }

            Spacer().frame(height: 100)

            Text("42")
                .tokenDragSource(for: NumberToken(digit: 42))
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

            if let editingLocation = numberEditor.editingNumber,
               let numberToken = manager.tokenAt(location: editingLocation) as? NumberToken {
                Text("Editing " + String(numberToken.digit))
            }

            if let error = manager.error?.error.description {
                Text("ERROR: \(error)")
            } else if let solution = try? manager.root.solved() {
                VStack {
                    Text(manager.root.getLatex())
                        .textSelection(.enabled)
                    FractionView(displayType: resultDisplayType, fraction: solution.normalized().simplified())
                        .onTapGesture {
                            withAnimation {
                                resultDisplayType = resultDisplayType.next()
                            }
                        }
                    Picker("", selection: $resultDisplayType) {
                        ForEach(ResultDisplayType.allCases, id: \.rawValue) { displayType in
                            Text("\(displayType.rawValue)")
                                .tag(displayType)
                        }
                    }
                }
            }
        }
        .font(.system(.body, design: .monospaced))
    }
}

enum ResultDisplayType: String, CaseIterable {
    case fraction = "Fraction"
    case mixedFraction = "Mixed Fraction"
    case decimal = "Decimal"

    func next() -> ResultDisplayType {
        switch self {
        case .fraction: .mixedFraction
        case .mixedFraction: .decimal
        case .decimal: .fraction
        }
    }
}

struct FractionView: View {
    var displayType: ResultDisplayType
    var fraction: Fraction<Int>

    var body: some View {
        switch displayType {
        case .fraction:
            if fraction.numerator.isMultiple(of: fraction.denominator) {
                decimalView
            } else {
                fractionView
            }
        case .mixedFraction:
            if fraction.numerator.isMultiple(of: fraction.denominator) {
                decimalView
            } else if fraction.isProper {
                fractionView
            } else {
                mixedFractionView
            }
        case .decimal:
            decimalView
        }
    }

    var fractionView: some View {
        VStack(spacing: 0) {
            Text(String(fraction.numerator))
                .overlay(alignment: .bottom) {
                    Color.black.frame(height: 2)
                        .offset(y: 1)
                }
            Text(String(fraction.denominator))
                .overlay(alignment: .top) {
                    Color.black.frame(height: 2)
                        .offset(y: -1)
                }
        }
    }

    var mixedFractionView: some View {
        HStack(spacing: 0) {
            Text(String(fraction.numerator / fraction.denominator))
            VStack(spacing: 0) {
                Text(String(abs(fraction.numerator % fraction.denominator)))
                    .overlay(alignment: .bottom) {
                        Color.black.frame(height: 2)
                            .offset(y: 1)
                    }
                Text(String(fraction.denominator))
                    .overlay(alignment: .top) {
                        Color.black.frame(height: 2)
                            .offset(y: -1)
                    }
            }
        }
    }

    @ViewBuilder var decimalView: some View {
        let value = Double(fraction.numerator)/Double(fraction.denominator)
        if value%1 == 0 {
            Text(String(Int(value)))
        } else {
            Text(String(value))
        }
    }
}

#Preview {
    ContentView()
}
