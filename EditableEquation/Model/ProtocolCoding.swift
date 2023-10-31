//
//  ProtocolCoding.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 1/11/23.
//

import Foundation

enum ProtocolCodingError: Error {
    case typeMismatch
    case eraseFailure
    case unregisteredName
    case encodingError
    case decodingError
}

struct ProtocolCodingProvider<P> {
    init<T: Codable>(type _: T.Type) {
        encode = { item in
            guard let item = item as? T else { throw ProtocolCodingError.typeMismatch }
            return try JSONEncoder().encode(item)
        }
        decode = { data in
            if let decoded = (try JSONDecoder().decode(T.self, from: data)) as? P {
                return decoded
            }
            throw ProtocolCodingError.eraseFailure
        }
    }

    var encode: (P) throws -> Data
    var decode: (Data) throws -> P
}

protocol ProtocolCoding {
    associatedtype WrappedProtocol
    /// A type conforming to `WrappedProtocol` that can be decoded and type casted to `WrappedProtocol`. Only needs to contain the name.
    associatedtype MinimalWrappedProtocol: Codable
    static var registeredProviders: [String: ProtocolCodingProvider<WrappedProtocol>] { get set }
    static var name: KeyPath<WrappedProtocol, String> { get }
}

extension ProtocolCoding {
    static func register<P: Codable>(type _: P.Type, for key: String) {
        registeredProviders[key] = .init(type: P.self)
    }

    static func encode(package: [WrappedProtocol]) throws -> String {
        var result: [String] = []
        for item in package {
            guard let provider = registeredProviders[item[keyPath: name]],
                  let encoded = String(data: try provider.encode(item), encoding: .utf8) else {
                throw ProtocolCodingError.unregisteredName
            }

            result.append(encoded)
        }

        if let finalEncoding = String(data: try JSONEncoder().encode(result), encoding: .utf8) {
            return finalEncoding
        }
        throw ProtocolCodingError.encodingError
    }

    static func decode(source: String) throws -> [WrappedProtocol] {
        guard let sourceData = source.data(using: .utf8) else { throw ProtocolCodingError.decodingError }
        let sourceArray = try JSONDecoder().decode([String].self, from: sourceData)

        var result: [WrappedProtocol] = []
        for item in sourceArray {
            guard let itemData = item.data(using: .utf8) else {
                throw ProtocolCodingError.decodingError
            }
            let minimal = try JSONDecoder().decode(MinimalWrappedProtocol.self, from: itemData)
            guard let minimalCasted = minimal as? WrappedProtocol,
                  let provider = registeredProviders[minimalCasted[keyPath: name]]
            else {
                throw ProtocolCodingError.typeMismatch
            }

            result.append(try provider.decode(itemData))
        }

        return result
    }
}

