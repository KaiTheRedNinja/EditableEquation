//
//  NumberTokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 30/10/23.
//

import SwiftUI

struct NumberTokenView: View {
    var number: NumberToken
    var treeLocation: TokenTreeLocation

    var body: some View {
        Text("\(number.digit)")
            .padding(.horizontal, 3)
            .overlay {
                SimpleLeadingTrailingDropOverlay(treeLocation: treeLocation)
            }
    }
}
