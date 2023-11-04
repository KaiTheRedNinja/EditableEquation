//
//  LinearGroup+Codable.swift
//
//
//  Created by Kai Quan Tay on 4/11/23.
//

import Foundation
import EditableEquationCore

extension LinearGroup: Codable {
    public enum Keys: CodingKey {
        case name, contents, hasBrackets
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(name, forKey: .name)
        try container.encode(contents.stringEncoded()?.data(using: .utf8), forKey: .contents)
        try container.encode(hasBrackets, forKey: .hasBrackets)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let contentsData = try container.decode(Data.self, forKey: .contents)
        guard let contentsString = String(data: contentsData, encoding: .utf8),
              let contents = [any EquationToken](decoding: contentsString)
        else {
            throw DecodingError.valueNotFound(
                Data.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "No contents found"
                )
            )
        }
        self.contents = contents
        self.hasBrackets = try container.decode(Bool.self, forKey: .hasBrackets)
    }
}
