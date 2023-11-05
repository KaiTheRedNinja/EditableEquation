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
                Button {
                    
                } label: {
                    Text("sin").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Button {

                } label: {
                    Text("log").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Button {

                } label: {
                    Text("x^n").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            HStack {
                Button {

                } label: {
                    Text("1").frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button {

                } label: {
                    Image(systemName: "multiply").frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button {

                } label: {
                    Image(systemName: "divide").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            HStack {
                Button {

                } label: {
                    Image(systemName: "parentheses").frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button {
                    
                } label: {
                    Image(systemName: "plus").frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button {

                } label: {
                    Image(systemName: "minus").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .font(.system(.largeTitle))
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)

        Text("42")
            .tokenDragSource(for: NumberToken(digit: 42))
            .onTapGesture {
                guard let insertionPoint = manager.insertionPoint else { return }
                withAnimation {
                    manager.insert(token: NumberToken(digit: 42), at: insertionPoint)
                }
            }
    }
}
