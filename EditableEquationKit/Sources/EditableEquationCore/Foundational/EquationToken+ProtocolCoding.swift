//
//  EquationToken+ProtocolCoding.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 1/11/23.
//

import Foundation

public enum EquationTokenCoding: ProtocolCoding {
    public typealias WrappedProtocol = any EquationToken
    public typealias MinimalWrappedProtocol = MinimalEquationToken

    public static var registeredProviders: [String: ProtocolCodingProvider<WrappedProtocol>] = [:]

    public static var name: KeyPath<WrappedProtocol, String> = \.name

    public struct MinimalEquationToken: EquationToken {
        public var id: UUID
        public var name: String
        public func getLatex() -> String { "" }
        public func canPrecede(_ other: (any EquationToken)?) -> Bool { fatalError() }
        public func canSucceed(_ other: (any EquationToken)?) -> Bool { fatalError() }
    }
}

public extension Array<any EquationToken> {
    /// Encodes the array as a JSON string
    func stringEncoded() -> String? {
        try? EquationTokenCoding.encode(package: self)
    }

    /// Decodes the array from a JSON string
    init?(decoding source: String) {
        if let decoded = try? EquationTokenCoding.decode(source: source) {
            self = decoded
        } else {
            print("Could not decode source")
            return nil
        }
    }
}
