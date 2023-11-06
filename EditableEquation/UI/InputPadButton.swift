//
//  InputPadButton.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 6/11/23.
//

import SwiftUI
import EditableEquationCore
import EditableEquationKit

@resultBuilder
enum InputPadOptionBuilder {
    static func buildBlock(
        _ content: InputPadOption...
    ) -> [InputPadOption] {
        content
    }
}

struct InputPadOption {
    var token: any EquationToken
    var view: AnyView
    var minimalView: AnyView

    init<V: View, M: View>(
        token: any EquationToken,
        @ViewBuilder view: @escaping () -> V,
        @ViewBuilder minimalView: @escaping () -> M
    ) {
        self.token = token
        self.view = AnyView(view())
        self.minimalView = AnyView(minimalView())
    }

    init<V: View>(token: any EquationToken, @ViewBuilder view: @escaping () -> V) {
        self.token = token
        self.view = AnyView(view())
        self.minimalView = AnyView(view())
    }
}

struct InputPadButton: View {
    var options: [InputPadOption]

    @EnvironmentObject var manager: EquationManager

    init(
        @InputPadOptionBuilder options: () -> [InputPadOption]
    ) {
        self.options = options()
    }

    var body: some View {
//        if let token = dataTuple.getToken(at: 0), let mainContent = dataTuple.getMainView(at: 0) {
//            content
//                .tokenDragSource(for: token, preview: { mainContent })
//        } else {
            content
//        }
    }

    var content: some View {
        Button {
            if let token = options.first?.token {
                insert(token: token)
            }
        } label: {
            Color.clear
                .overlay {
                    if let mainContent = options.first?.view {
                        mainContent
                            .font(.largeTitle)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if options.count >= 2 {
                        options[1].view
                            .font(.title3)
                            .padding(5)
                            .opacity(0.4)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if options.count >= 3 {
                        options[2].view
                            .font(.title3)
                            .padding(5)
                            .opacity(0.4)
                    }
                }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
        .contextMenu {
            ForEach(0..<options.count, id: \.self) { index in
                Button {
                    insert(token: options[index].token)
                } label: {
                    options[index].minimalView
                }
            }
        }
    }

    func insert(token: any EquationToken) {
        guard let insertionPoint = manager.insertionPoint else { return }
        withAnimation {
            manager.insert(token: token, at: insertionPoint, editIfNumberToken: true)
        }
    }
}
