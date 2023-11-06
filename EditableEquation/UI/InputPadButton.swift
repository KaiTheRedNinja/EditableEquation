//
//  InputPadButton.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 6/11/23.
//

import SwiftUI
import EditableEquationCore

struct InputPadButton<Token: EquationToken, CT: View, Main: View, Alt1: View, Alt2: View>: View {
    var dragToken: Token
    var onTap: () -> Void
    var onLongHold: () -> CT

    var mainContent: () -> Main
    var alt1: () -> Alt1
    var alt2: () -> Alt2

    init(
        dragToken: Token,
        onTap: @escaping () -> Void,
        @ViewBuilder onLongHold: @escaping () -> CT,
        @ViewBuilder mainContent: @escaping () -> Main,
        @ViewBuilder alt1: @escaping () -> Alt1,
        @ViewBuilder alt2: @escaping () -> Alt2
    ) {
        self.dragToken = dragToken
        self.onTap = onTap
        self.onLongHold = onLongHold
        self.mainContent = mainContent
        self.alt1 = alt1
        self.alt2 = alt2
    }

    init(
        dragToken: Token,
        onTap: @escaping () -> Void,
        @ViewBuilder onLongHold: @escaping () -> CT,
        @ViewBuilder mainContent: @escaping () -> Main,
        @ViewBuilder alt1: @escaping () -> Alt1
    ) where Alt2 == EmptyView {
        self.dragToken = dragToken
        self.onTap = onTap
        self.onLongHold = onLongHold
        self.mainContent = mainContent
        self.alt1 = alt1
        self.alt2 = { EmptyView() }
    }

    init(
        dragToken: Token,
        onTap: @escaping () -> Void,
        @ViewBuilder mainContent: @escaping () -> Main
    ) where CT == EmptyView, Alt1 == EmptyView, Alt2 == EmptyView {
        self.dragToken = dragToken
        self.onTap = onTap
        self.onLongHold = { EmptyView() }
        self.mainContent = mainContent
        self.alt1 = { EmptyView() }
        self.alt2 = { EmptyView() }
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            Color.clear
                .overlay {
                    mainContent()
                        .font(.largeTitle)
                }
                .overlay(alignment: .topLeading) {
                    alt1()
                        .font(.title3)
                        .padding(5)
                        .opacity(0.4)
                }
                .overlay(alignment: .topTrailing) {
                    alt2()
                        .font(.title3)
                        .padding(5)
                        .opacity(0.4)
                }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
        .contextMenu {
            onLongHold()
        }
        .tokenDragSource(for: dragToken) {
            mainContent()
        }
    }
}
