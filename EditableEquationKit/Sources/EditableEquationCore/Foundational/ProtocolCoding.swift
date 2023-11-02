//
//  ProtocolCoding.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 1/11/23.
//

import Foundation

public enum ProtocolCodingError: Error {
    case typeMismatch
    case eraseFailure
    case unregisteredName
    case encodingError
    case decodingError
}

/// A struct that allows type casting a specified type to a parent type
///
/// `P` is an associated generic, wheras `T`, used in the initialiser, is discarded once `init` returns.
public struct ProtocolCodingProvider<P> {
    public init<T: Codable>(type _: T.Type) {
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

/// A protocol that implements methods to make `any [Protocol]` conform to codable.
///
/// Protocols using `ProtocolCoding` must have a property to identify its type, and all types that
/// are to be decoded by `ProtocolCoding` must be registered by ``register(type:for:)``.
public protocol ProtocolCoding {
    associatedtype WrappedProtocol
    /// A type conforming to `WrappedProtocol` that can be decoded and type casted to `WrappedProtocol`. Only needs to contain the name.
    associatedtype MinimalWrappedProtocol: Codable
    /// A dictionary of providers to their names
    static var registeredProviders: [String: ProtocolCodingProvider<WrappedProtocol>] { get set }
    /// A keypath to the name in a `WrappedProtocol`
    static var name: KeyPath<WrappedProtocol, String> { get }
}

public extension ProtocolCoding {
    /// Registers a type wtih a name
    static func register<P: Codable>(type _: P.Type, for key: String) {
        registeredProviders[key] = .init(type: P.self)
    }

    /// Encodes a single item into a string
    static func encodeSingle(item: WrappedProtocol) throws -> String {
        guard let provider = registeredProviders[item[keyPath: name]],
              let encoded = String(data: try provider.encode(item), encoding: .utf8) else {
            throw ProtocolCodingError.unregisteredName
        }

        return encoded
    }

    /// Decodes a string into a single item
    static func decodeSingle(source: String) throws -> WrappedProtocol {
        guard let itemData = source.data(using: .utf8) else {
            throw ProtocolCodingError.decodingError
        }
        let minimal = try JSONDecoder().decode(MinimalWrappedProtocol.self, from: itemData)
        guard let minimalCasted = minimal as? WrappedProtocol,
              let provider = registeredProviders[minimalCasted[keyPath: name]]
        else {
            throw ProtocolCodingError.typeMismatch
        }

        return try provider.decode(itemData)
    }

    /// Encodes multiple items into a string
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

    /// Decodes a string into multiple items
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

