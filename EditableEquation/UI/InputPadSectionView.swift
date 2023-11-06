//
//  InputPadSectionView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 5/11/23.
//

import SwiftUI
import EditableEquationKit

struct InputPadSectionView: View {
    @ObservedObject var manager: EquationManager

    var body: some View {
        VStack {
            HStack {
                trigButton
                logButton
                exponentButton
            }

            HStack {
                numberButton
                multiplyButton
                divideButton
            }

            HStack {
                bracketButton
                plusButton
                minusButton
            }
        }
        .environmentObject(manager)
    }

    var trigButton: some View {
        InputPadButton {
            InputPadOption(token: NumberToken(digit: 69)) {
                Text("sin")
            }
            InputPadOption(token: NumberToken(digit: 69)) {
                Text("cos")
            }
            InputPadOption(token: NumberToken(digit: 69)) {
                Text("tan")
            }
        }
    }

    var logButton: some View {
        InputPadButton {
            InputPadOption(token: NumberToken(digit: 69)) {
                Text("log")
                    .padding(.bottom, 8)
                    .padding(.trailing, 18)
                    .overlay(alignment: .bottomTrailing) {
                        Text("10")
                            .font(.system(.title3, design: .serif))
                    }
            } minimalView: {
                Text("Log10")
            }

            InputPadOption(token: NumberToken(digit: 69)) {
                Text("ln")
            }

            InputPadOption(token: NumberToken(digit: 69)) {
                Text("log")
                    .font(.system(.title3))
                    .padding(.bottom, 6)
                    .padding(.trailing, 10)
                    .overlay(alignment: .bottomTrailing) {
                        Text("n")
                            .font(.system(.footnote, design: .serif))
                    }
                    .padding(.trailing, -2)
            }
        }
    }

    var exponentButton: some View {
        InputPadButton {
            InputPadOption(token: NumberToken(digit: 69)) {
                Text("x")
                    .font(.system(.largeTitle, design: .serif))
                    .padding(.top, 8)
                    .padding(.trailing, 14)
                    .overlay(alignment: .topTrailing) {
                        Text("2")
                            .font(.system(.title3, design: .serif))
                    }
            } minimalView: {
                Text("x^2")
            }

            InputPadOption(token: NumberToken(digit: 69)) {
                Text("x^n")
            }

            InputPadOption(token: NumberToken(digit: 69)) {
                Image(systemName: "x.squareroot")
                    .font(.system(.title2, design: .serif))
            } minimalView: {
                Text("sqrt(x)")
            }
        }
    }

    var numberButton: some View {
        InputPadButton {
            InputPadOption(token: NumberToken(digit: 1)) {
                Text("1")
            }

            InputPadOption(token: NumberToken(digit: 1)) {
                Text("Ans")
                    .lineLimit(1)
            }
        }
    }

    var multiplyButton: some View {
        InputPadButton {
            InputPadOption(token: LinearOperationToken(operation: .times)) {
                Image(systemName: "multiply")
            }
        }
    }

    var divideButton: some View {
        InputPadButton {
            InputPadOption(token: LinearOperationToken(operation: .divide)) {
                Image(systemName: "divide")
            } minimalView: {
                Label("Divide", systemImage: "divide")
            }

            InputPadOption(token: DivisionGroup(numerator: [], denominator: [])) {
                Image(systemName: "rectangle.grid.1x2")
            } minimalView: {
                Label("Fraction", systemImage: "rectangle.grid.1x2")
            }
        }
    }

    var bracketButton: some View {
        InputPadButton {
            InputPadOption(token: LinearGroup(contents: [], hasBrackets: true)) {
                Image(systemName: "parentheses")
            } minimalView: {
                Label("Brackets", systemImage: "parentheses")
            }
        }
    }

    var plusButton: some View {
        InputPadButton {
            InputPadOption(token: LinearOperationToken(operation: .plus)) {
                Image(systemName: "plus")
            }
        }
    }

    var minusButton: some View {
        InputPadButton {
            InputPadOption(token: LinearOperationToken(operation: .minus)) {
                Image(systemName: "minus")
            }
        }
    }
}
