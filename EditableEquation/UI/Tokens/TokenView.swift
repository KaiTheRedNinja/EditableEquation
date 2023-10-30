//
//  TokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

struct TokenView: View {
    var token: EquationToken
    var treeLocation: TokenTreeLocation

    var body: some View {
        switch token {
        case .number(let numberToken):
            NumberTokenView(number: numberToken, treeLocation: treeLocation)
        case .linearOperation(let linearOperationToken):
            LinearOperationView(linearOperation: linearOperationToken, treeLocation: treeLocation)
        case .linearGroup(let linearGroup):
            LinearGroupView(linearGroup: linearGroup, treeLocation: treeLocation)
        case .divisionGroup(let divisionGroup):
            DivisionGroupView(divisionGroup: divisionGroup, treeLocation: treeLocation)
        }
    }
}
