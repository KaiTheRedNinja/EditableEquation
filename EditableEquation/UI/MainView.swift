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
            .font(.title)
            .padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .overlay(alignment: .bottomTrailing) {
            HStack {
                if let error = manager.error?.error.description {
                    ScrollView(.horizontal) {
                        Text("\(error)")
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                    }
                } else if let solution = try? manager.root.solved() {
                    ResultDisplayView(
                        displayType: resultDisplayType,
                        fraction: solution.normalized().simplified()
                    )
                    .onTapGesture {
                        withAnimation {
                            resultDisplayType = resultDisplayType.next()
                        }
                    }
                    .contextMenu {
                        ForEach(ResultDisplayType.allCases, id: \.rawValue) { displayType in
                            Button("\(displayType.rawValue)") {
                                resultDisplayType = displayType
                            }
                        }
                    }
                }
            }
            .bold()
            .padding(5)
            .background {
                GroupBox {
                    Color.clear
                }
                .backgroundStyle(.thinMaterial)
            }
        }
    }
}

#Preview {
    MainView(initialRoot: defaultRoot)
}
