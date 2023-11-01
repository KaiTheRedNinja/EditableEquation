//
//  EquationToken+ProtocolCoding.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 1/11/23.
//

import Foundation

enum EquationTokenCoding: ProtocolCoding {
    typealias WrappedProtocol = any SingleEquationToken
    typealias MinimalWrappedProtocol = MinimalEquationToken

    static var registeredProviders: [String : ProtocolCodingProvider<WrappedProtocol>] = [
        "Number": .init(type: NumberToken.self),
        "LinearOperation": .init(type: LinearOperationToken.self),
        "LinearGroup": .init(type: LinearGroup.self),
        "DivisionGroup": .init(type: DivisionGroup.self)
    ]

    static var name: KeyPath<WrappedProtocol, String> = \.name

    struct MinimalEquationToken: SingleEquationToken {
        var id: UUID
        var name: String
        func canPrecede(_ other: (any SingleEquationToken)?) -> Bool { fatalError() }
        func canSucceed(_ other: (any SingleEquationToken)?) -> Bool { fatalError() }
    }
}

extension Array<any SingleEquationToken> {
    func stringEncoded() -> String? {
        try? EquationTokenCoding.encode(package: self)
    }

    init?(decoding source: String) {
        if let decoded = try? EquationTokenCoding.decode(source: source) {
            self = decoded
        } else {
            print("Could not decode source")
            return nil
        }
    }
}

