//
//  NumberEditView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 5/11/23.
//

import SwiftUI
import EditableEquationKit
import EditableEquationCore

struct NumberEditView: View {
    var manager: EquationManager
    var path: TokenTreeLocation
    @State var token: NumberToken

    @FocusState var focusedField: Bool?

    init(manager: EquationManager, path: TokenTreeLocation, token: NumberToken) {
        self.manager = manager
        self.path = path
        self._token = .init(initialValue: token)
    }

    var body: some View {
        TextField("", value: $token.digit, formatter: formatter)
            .keyboardType(.numberPad)
            .onSubmit {
                manager.numberEditor?.editingNumber = nil
            }
            .submitLabel(.done)
            .onChange(of: token.digit) { _, _ in
                manager.replace(token: token, at: path)
            }
            .lineLimit(1)
            .focused($focusedField, equals: true)
            .onAppear {
                focusedField = true
            }
            .onChange(of: focusedField) { _, focus in
                if focus == true {
                    DispatchQueue.main.async {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil
                        )
                    }
                }
            }
    }

    var formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.allowsFloats = false
        return formatter
    }()
}
