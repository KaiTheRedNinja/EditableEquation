//
//  SolutionValue.swift
//
//
//  Created by Kai Quan Tay on 3/11/23.
//

import Foundation

//protocol SolutionValue: Numeric {
//    var decimalValue: Double { get }
//}
//
//public enum Solution {
//    case fraction(FractionValue)
//    case double(Double)
//}
//
//extension Solution: SolutionValue {
//    var decimalValue: Double {
//        switch self {
//        case .fraction(let fractionValue):
//            fractionValue.decimalValue
//        case .double(let double):
//            double.decimalValue
//        }
//    }
//
//    public typealias Magnitude = Double
//    public var magnitude: Double { abs(decimalValue) }
//
//    public init?<T>(exactly source: T) where T : BinaryInteger {
//        guard let frac = FractionValue(exactly: source) else { return nil }
//        self = .fraction(frac)
//    }
//
//    public init(integerLiteral value: Int) {
//        self = .fraction(FractionValue(integerLiteral: value))
//    }
//
//    public static func * (lhs: Solution, rhs: Solution) -> Solution {
//        switch lhs {
//        case .fraction(let lhsFractionValue):
//            switch rhs {
//            case .fraction(let rhsFractionValue):
//                return .fraction(FractionValue(
//                    numerator: lhsFractionValue.numerator * rhsFractionValue.numerator,
//                    denominator: lhsFractionValue.denominator * rhsFractionValue.denominator
//                ))
//            default: break
//            }
//        default: break
//        }
//
//        return .double(lhs.decimalValue*rhs.decimalValue)
//    }
//
//    public static func + (lhs: Solution, rhs: Solution) -> Solution {
//        switch lhs {
//        case .fraction(let lhsFractionValue):
//            switch rhs {
//            case .fraction(let rhsFractionValue):
//                return .fraction(FractionValue(
//                    numerator: lhsFractionValue.numerator*rhsFractionValue.denominator +
//                               rhsFractionValue.numerator*lhsFractionValue.denominator,
//                    denominator: lhsFractionValue.denominator*rhsFractionValue.denominator
//                ))
//            default: break
//            }
//        default: break
//        }
//
//        return .double(lhs.decimalValue+rhs.decimalValue)
//    }
//
//    public static func / (lhs: Solution, rhs: Solution) -> Solution {
//        switch lhs {
//        case .fraction(let lhsFractionValue):
//            switch rhs {
//            case .fraction(let rhsFractionValue):
//                return .fraction(FractionValue(
//                    numerator: lhsFractionValue.numerator * rhsFractionValue.denominator,
//                    denominator: lhsFractionValue.denominator * rhsFractionValue.numerator
//                ))
//            default: break
//            }
//        default: break
//        }
//
//        return .double(lhs.decimalValue/rhs.decimalValue)
//    }
//
//    public static func - (lhs: Solution, rhs: Solution) -> Solution {
//        switch lhs {
//        case .fraction(let lhsFractionValue):
//            switch rhs {
//            case .fraction(let rhsFractionValue):
//                return .fraction(FractionValue(
//                    numerator: lhsFractionValue.numerator*rhsFractionValue.denominator -
//                               rhsFractionValue.numerator*lhsFractionValue.denominator,
//                    denominator: lhsFractionValue.denominator*rhsFractionValue.denominator
//                ))
//            default: break
//            }
//        default: break
//        }
//
//        return .double(lhs.decimalValue-rhs.decimalValue)
//    }
//
//    public static func *= (lhs: inout Solution, rhs: Solution) {
//        lhs = lhs*rhs
//    }
//}
//
//extension Double: SolutionValue {
//    var decimalValue: Double { self }
//}
