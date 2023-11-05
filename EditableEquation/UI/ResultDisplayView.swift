//
//  ResultDisplayView.swift
//  EditableEquation
//
//  Created by Kai Quan Tay on 5/11/23.
//

import SwiftUI
import Rationals

enum ResultDisplayType: String, CaseIterable {
    case fraction = "Fraction"
    case mixedFraction = "Mixed Fraction"
    case decimal = "Decimal"

    func next() -> ResultDisplayType {
        switch self {
        case .fraction: .mixedFraction
        case .mixedFraction: .decimal
        case .decimal: .fraction
        }
    }
}

struct ResultDisplayView: View {
    var displayType: ResultDisplayType
    var fraction: Fraction<Int>

    var body: some View {
        switch displayType {
        case .fraction:
            if fraction.numerator.isMultiple(of: fraction.denominator) {
                decimalView
            } else {
                fractionView
            }
        case .mixedFraction:
            if fraction.numerator.isMultiple(of: fraction.denominator) {
                decimalView
            } else if fraction.isProper {
                fractionView
            } else {
                mixedFractionView
            }
        case .decimal:
            decimalView
        }
    }

    var fractionView: some View {
        VStack(spacing: 0) {
            Text(String(fraction.numerator))
                .overlay(alignment: .bottom) {
                    Color.black.frame(height: 2)
                        .offset(y: 1)
                }
            Text(String(fraction.denominator))
                .overlay(alignment: .top) {
                    Color.black.frame(height: 2)
                        .offset(y: -1)
                }
        }
    }

    var mixedFractionView: some View {
        HStack(spacing: 0) {
            Text(String(fraction.numerator / fraction.denominator))
            VStack(spacing: 0) {
                Text(String(abs(fraction.numerator % fraction.denominator)))
                    .overlay(alignment: .bottom) {
                        Color.black.frame(height: 2)
                            .offset(y: 1)
                    }
                Text(String(fraction.denominator))
                    .overlay(alignment: .top) {
                        Color.black.frame(height: 2)
                            .offset(y: -1)
                    }
            }
        }
    }

    @ViewBuilder var decimalView: some View {
        let value = Double(fraction.numerator)/Double(fraction.denominator)
        if value%1 == 0 {
            Text(String(Int(value)))
        } else {
            Text(String(value))
        }
    }
}

#Preview {
    VStack {
        ForEach(ResultDisplayType.allCases, id: \.rawValue) { displayType in
            ResultDisplayView(displayType: displayType, fraction: .init(49, on: 13))
        }
    }
}
