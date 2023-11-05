//
//  NumberEditor.swift
//
//
//  Created by Kai Quan Tay on 5/11/23.
//

import Foundation
import EditableEquationCore

public class NumberEditor: ObservableObject {
    @Published public var editingNumber: TokenTreeLocation?

    public init(editingNumber: TokenTreeLocation? = nil) {
        self.editingNumber = editingNumber
    }
}
