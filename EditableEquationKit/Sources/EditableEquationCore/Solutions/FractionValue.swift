//
//  FractionValue.swift
//  
//
//  Created by Kai Quan Tay on 3/11/23.
//

import Foundation

//public struct FractionValue: SolutionValue {
//    public var numerator: Int
//    public var denominator: Int
//
//    public init(numerator: Int, denominator: Int) {
//        self.numerator = numerator
//        self.denominator = denominator
//        optimise()
//    }
//
//    public var decimalValue: Double {
//        Double(numerator)/Double(denominator)
//    }
//
//    public func optimised() -> FractionValue {
//        guard denominator != 0 else { return self }
//        let gcd = abs(greatestCommonDenominator(first: numerator, second: denominator))
//
//        return .init(
//            numerator: numerator/gcd,
//            denominator: denominator/gcd
//        )
//    }
//
//    mutating func optimise() {
//        self = self.optimised()
//    }
//
//    private func greatestCommonDenominator(first: Int, second: Int) -> Int {
//        return second == 0 ? first : greatestCommonDenominator(first: second, second: first % second)
//    }
//}
//
//extension FractionValue: Numeric {
//    public typealias Magnitude = Double
//    public var magnitude: Double { abs(decimalValue) }
//
//    public init?<T>(exactly source: T) where T : BinaryInteger {
//        numerator = Int(source)
//        denominator = 1
//    }
//
//    public init(integerLiteral value: Int) {
//        numerator = value
//        denominator = 1
//    }
//
//    public static func * (lhs: FractionValue, rhs: FractionValue) -> FractionValue {
//        return .init(
//            numerator: lhs.numerator * rhs.numerator,
//            denominator: lhs.denominator * rhs.denominator
//        )
//    }
//
//    public static func + (lhs: FractionValue, rhs: FractionValue) -> FractionValue {
//        return .init(
//            numerator: lhs.numerator*rhs.denominator + rhs.numerator*lhs.denominator,
//            denominator: lhs.denominator*rhs.denominator
//        )
//    }
//
//    public static func *= (lhs: inout FractionValue, rhs: FractionValue) {
//        lhs = lhs*rhs
//    }
//
//    public static func - (lhs: FractionValue, rhs: FractionValue) -> FractionValue {
//        return .init(
//            numerator: lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator,
//            denominator: lhs.denominator*rhs.denominator
//        )
//    }
//}
