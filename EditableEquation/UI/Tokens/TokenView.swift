//
//  TokenView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 28/10/23.
//

import SwiftUI

protocol TokenView: View {
    var treeLocation: TokenTreeLocation { get }
    var namespace: Namespace.ID { get }
}

struct GeneralTokenView: TokenView {
    var token: any SingleEquationToken
    var treeLocation: TokenTreeLocation

    var namespace: Namespace.ID

    var body: some View {
        if let numberToken = token as? NumberToken {
            NumberTokenView(number: numberToken, treeLocation: treeLocation, namespace: namespace)
        }
        if let linearOperationToken = token as? LinearOperationToken {
            LinearOperationView(linearOperation: linearOperationToken, treeLocation: treeLocation, namespace: namespace)
        }
        if let linearGroup = token as? LinearGroup {
            LinearGroupView(linearGroup: linearGroup, treeLocation: treeLocation, namespace: namespace)
        }
        if let divisionGroup = token as? DivisionGroup {
            DivisionGroupView(divisionGroup: divisionGroup, treeLocation: treeLocation, namespace: namespace)
        }
    }
}
