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
    }

    var trigButton: some View {
        InputPadButton(
            dragToken: NumberToken(digit: 69)
        ) {
            // TODO: Implement trig
        } onLongHold: {
            Button("sin") {

            }.disabled(true)
            Button("cos") {

            }.disabled(true)
            Button("tan") {

            }.disabled(true)
        } mainContent: {
            Text("sin")
        } alt1: {
            Text("cos")
        } alt2: {
            Text("tan")
        }
    }

    var logButton: some View {
        InputPadButton(
            dragToken: NumberToken(digit: 69)
        ) {
            // TODO: implement logarithms
        } onLongHold: {
            Button("Log10") {

            }.disabled(true)
            Button("Ln") {

            }.disabled(true)
            Button("Logn") {

            }.disabled(true)
        } mainContent: {
            Text("log")
                .padding(.bottom, 8)
                .padding(.trailing, 18)
                .overlay(alignment: .bottomTrailing) {
                    Text("10")
                        .font(.system(.title3, design: .serif))
                }
        } alt1: {
            Text("ln")
        } alt2: {
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

    var exponentButton: some View {
        InputPadButton(
            dragToken: NumberToken(digit: 69)
        ) {
            // TODO: implement exponentials
        } onLongHold: {
            Button("x^2") {

            }.disabled(true)
            Button("x^n") {

            }.disabled(true)
            Button("sqrt(x)") {

            }.disabled(true)
        } mainContent: {
            Text("x")
                .font(.system(.largeTitle, design: .serif))
                .padding(.top, 8)
                .padding(.trailing, 14)
                .overlay(alignment: .topTrailing) {
                    Text("2")
                        .font(.system(.title3, design: .serif))
                }
        } alt1: {
            Text("x")
                .font(.system(.title3, design: .serif))
                .padding(.top, 6)
                .padding(.trailing, 8)
                .overlay(alignment: .topTrailing) {
                    Text("n")
                        .font(.system(.footnote, design: .serif))
                }
                .padding(.top, -6)
        } alt2: {
            Image(systemName: "x.squareroot")
                .font(.system(.title2, design: .serif))
        }
    }

    var numberButton: some View {
        InputPadButton(
            dragToken: NumberToken(digit: 1)
        ) {
            guard let insertionPoint = manager.insertionPoint else { return }
            withAnimation {
                manager.insert(token: NumberToken(digit: 1), at: insertionPoint)
            }
        } onLongHold: {
            Button("Number") {

            }
            Button("Prev Answer") {

            }.disabled(true)
        } mainContent: {
            Text("1")
        } alt1: {
            Text("Ans")
                .lineLimit(1)
        }
    }

    var multiplyButton: some View {
        InputPadButton(
            dragToken: LinearOperationToken(operation: .times)
        ) {
            // TODO: this
        } mainContent: {
            Image(systemName: "multiply").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var divideButton: some View {
        InputPadButton(
            dragToken: LinearOperationToken(operation: .divide)
        ) {
            // TODO: this
        } onLongHold: {
            Button {

            } label: {
                Label("Divide", systemImage: "divide")
            }
            Button {

            } label: {
                Label("Fraction", systemImage: "rectangle.grid.1x2")
            }
        } mainContent: {
            Image(systemName: "divide").frame(maxWidth: .infinity, maxHeight: .infinity)
        } alt1: {
            Image(systemName: "rectangle.grid.1x2")
        }
    }

    var bracketButton: some View {
        InputPadButton(
            dragToken: LinearGroup(contents: [], hasBrackets: true)
        ) {
            // TODO: this
        } mainContent: {
            Image(systemName: "parentheses").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var plusButton: some View {
        InputPadButton(
            dragToken: LinearOperationToken(operation: .plus)
        ) {
            // TODO: this
        } mainContent: {
            Image(systemName: "plus").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var minusButton: some View {
        InputPadButton(
            dragToken: LinearOperationToken(operation: .minus)
        ) {
            // TODO: this
        } mainContent: {
            Image(systemName: "minus").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
