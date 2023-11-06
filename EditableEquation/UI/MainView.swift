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

    init(initialRoot: LinearGroup) {
        self.manager = .init(
            root: initialRoot
        )
        self.numberEditor = .init()
        manager.numberEditor = self.numberEditor
    }

    @State var resultDisplayType: ResultDisplayType = .fraction

    var body: some View {
        VStack(spacing: 14) {
            GroupBox {
                equationDisplaySection
            }
            NavigationSectionView(manager: manager, numberEditor: numberEditor)
            InputPadSectionView(manager: manager)
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
        .frame(height: 130)
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
}

#Preview {
    MainView(initialRoot: defaultRoot)
}
