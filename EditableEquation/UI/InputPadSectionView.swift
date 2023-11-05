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
                    Color.clear
                        .overlay {
                            Text("sin")
                        }
                        .overlay(alignment: .topLeading) {
                            Text("cos")
                                .font(.title3)
                                .padding(5)
                                .opacity(0.4)
                        }
                        .overlay(alignment: .topTrailing) {
                            Text("tan")
                                .font(.title3)
                                .padding(5)
                                .opacity(0.4)
                        }
                }
                Button {

                } label: {
                    Color.clear
                        .overlay {
                            Text("log")
                                .padding(.bottom, 8)
                                .padding(.trailing, 18)
                                .overlay(alignment: .bottomTrailing) {
                                    Text("10")
                                        .font(.system(.title3, design: .serif))
                                }
                        }
                        .overlay(alignment: .topLeading) {
                            Text("ln")
                                .font(.system(.title2))
                                .padding(5)
                                .opacity(0.4)
                        }
                        .overlay(alignment: .topTrailing) {
                            Text("log")
                                .font(.system(.title2))
                                .padding(.bottom, 6)
                                .padding(.trailing, 10)
                                .overlay(alignment: .bottomTrailing) {
                                    Text("n")
                                        .font(.system(.footnote, design: .serif))
                                }
                                .padding(.top, 5)
                                .padding(.trailing, -2)
                                .opacity(0.4)
                        }
                        .padding(.top, 6)
                        .padding(.trailing, 8)
                }
                Button {

                } label: {
                    Color.clear
                        .overlay {
                            Text("x")
                                .font(.system(.largeTitle, design: .serif))
                                .padding(.top, 8)
                                .padding(.trailing, 14)
                                .overlay(alignment: .topTrailing) {
                                    Text("2")
                                        .font(.system(.title3, design: .serif))
                                }
                        }
                        .overlay(alignment: .topLeading) {
                            Text("x")
                                .font(.system(.title3, design: .serif))
                                .padding(.top, 6)
                                .padding(.trailing, 8)
                                .overlay(alignment: .topTrailing) {
                                    Text("n")
                                        .font(.system(.footnote, design: .serif))
                                }
                                .padding(5)
                                .opacity(0.4)
                        }
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "x.squareroot")
                                .font(.system(.title2, design: .serif))
                                .padding(.top, 9)
                                .padding(.trailing, 6)
                                .opacity(0.4)
                        }
                }
            }

            HStack {
                Button {
                    guard let insertionPoint = manager.insertionPoint else { return }
                    withAnimation {
                        manager.insert(token: NumberToken(digit: 42), at: insertionPoint)
                    }
                } label: {
                    Color.clear
                        .overlay {
                            Text("1").frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .overlay(alignment: .topLeading) {
                            Text("Ans")
                                .lineLimit(1)
                                .font(.title3)
                                .padding(5)
                                .opacity(0.4)
                        }
                }
                .tokenDragSource(for: NumberToken(digit: 1))

                Button {

                } label: {
                    Image(systemName: "multiply").frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button {

                } label: {
                    Color.clear
                        .overlay {
                            Image(systemName: "divide").frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .overlay(alignment: .topLeading) {
                            Image(systemName: "rectangle.grid.1x2")
                                .font(.title3)
                                .padding(5)
                                .opacity(0.4)
                        }
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
    }
}
