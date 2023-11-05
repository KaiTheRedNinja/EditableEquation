//
//  MainView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 5/11/23.
//

import SwiftUI
import EditableEquationKit
import EditableEquationUI

struct MainView: View {
    @ObservedObject var manager: EquationManager

    @ObservedObject var numberEditor: NumberEditor

    init() {
        self.manager = .init(
            root: defaultRoot
        )
        self.numberEditor = .init()
        manager.numberEditor = self.numberEditor
    }

    @State var resultDisplayType: ResultDisplayType = .fraction

    var body: some View {
        VStack {
            GroupBox {
                equationDisplaySection
            }
            numberEditSection
            inputPadSection
        }
        .animation(.easeOut(duration: 0.25), value: numberEditor.editingNumber.debugDescription)
        .padding(.horizontal, 14)
        .font(.system(.body, design: .monospaced))
    }

    @ViewBuilder var equationDisplaySection: some View {
        ScrollView([.horizontal, .vertical]) {
            EquationView(
                manager: manager
            )
            .font(.title2)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .safeAreaInset(edge: .bottom) {
            HStack {
                if let error = manager.error?.error.description {
                    Spacer().frame(height: 3)
                        .layoutPriority(0)
                    Text("\(error)")
                        .layoutPriority(1)
                } else if let solution = try? manager.root.solved() {
                    Spacer().frame(height: 3)
                        .layoutPriority(0)
                    Picker("", selection: $resultDisplayType) {
                        ForEach(ResultDisplayType.allCases, id: \.rawValue) { displayType in
                            Text("\(displayType.rawValue)")
                                .tag(displayType)
                        }
                    }
                    .layoutPriority(1)
                    ResultDisplayView(
                        displayType: resultDisplayType,
                        fraction: solution.normalized().simplified()
                    )
                    .onTapGesture {
                        withAnimation {
                            resultDisplayType = resultDisplayType.next()
                        }
                    }
                    .layoutPriority(2)
                }
            }
            .bold()
        }
    }

    @ViewBuilder var numberEditSection: some View {
        if let editingLocation = numberEditor.editingNumber,
           let numberToken = manager.tokenAt(location: editingLocation) as? NumberToken {
            GroupBox {
                HStack {
                    Spacer()
                    Text(String(numberToken.digit))
                    Button {
                        numberEditor.editingNumber = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    @ViewBuilder var inputPadSection: some View {
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
        Text("42")
            .tokenDragSource(for: NumberToken(digit: 42))
            .onTapGesture {
                guard let insertionPoint = manager.insertionPoint else { return }
                withAnimation {
                    manager.insert(token: NumberToken(digit: 42), at: insertionPoint)
                }
            }

        Spacer()
    }
}

#Preview {
    MainView()
}
