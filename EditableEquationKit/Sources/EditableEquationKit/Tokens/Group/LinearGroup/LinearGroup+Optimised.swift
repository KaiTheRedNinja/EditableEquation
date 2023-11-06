//
//  LinearGroup+Optimised.swift
//
//
//  Created by Kai Quan Tay on 6/11/23.
//

import Foundation
import EditableEquationCore

extension LinearGroup {
    /// Optimises the LinearGroup's representation. It returns a modified version of this instance,
    /// keeping the ID the same. This function is to be called every time the equation is modified,
    /// and has no effects on the equation's appearance.
    public func optimised() -> any EquationToken {
        var contentsCopy = contents

        // optimise everything
        for index in 0..<contentsCopy.count {
            contentsCopy[index] = contentsCopy[index].groupRepresentation?.optimised() ?? contentsCopy[index]
        }

        // break out non-bracket LinearGroups
        breakBracketlessLinearGroups(&contentsCopy)

        // Turn consecutive number tokens into a single token
        combineConsecutiveNumbers(&contentsCopy)

        // Turn negative number tokens into a positive number token and a negative sign
        normaliseNegativeNumbers(&contentsCopy)

        return LinearGroup(id: self.id, contents: contentsCopy, hasBrackets: self.hasBrackets)
    }

    // For some of these, we iterate over the array backwards, to prevent access errors
    private func breakBracketlessLinearGroups(_ contentsCopy: inout [any EquationToken]) {
        // break out non-bracket LinearGroups
        for index in (0..<contentsCopy.count).reversed() {
            if let linearGroup = contentsCopy[index] as? LinearGroup {
                if !linearGroup.hasBrackets {
                    contentsCopy.remove(at: index)
                    guard let linearOptimised = linearGroup.optimised() as? LinearGroup else {
                        continue
                    }
                    contentsCopy.insert(contentsOf: linearOptimised.contents, at: index)
                }
            }
        }
    }

    private func combineConsecutiveNumbers(_ contentsCopy: inout [any EquationToken]) {
        // Turn consecutive number tokens into a single token
        var lastNumberToken: Int?
        for index in (0..<contentsCopy.count).reversed() {
            if let number = contentsCopy[index] as? NumberToken {
                if let lastNumberToken {
                    // get the last token, and integrate it into this token. Simple string concat.
                    contentsCopy.remove(at: index+1)

                    let lastNumberTokenMagnitude = Int(log(Double(lastNumberToken))/log(10))

                    let newDigit = lastNumberToken + number.digit * Int(pow(10, Double(1 + lastNumberTokenMagnitude)))

                    contentsCopy[index] = NumberToken(
                        id: contentsCopy[index].id,
                        digit: newDigit
                    )
                }
                lastNumberToken = number.digit
            } else {
                lastNumberToken = nil
            }
        }
    }

    private func normaliseNegativeNumbers(_ contentsCopy: inout [any EquationToken]) {
        // Turn negative number tokens into a positive number token and a negative sign
        for index in (0..<contentsCopy.count).reversed() {
            if let number = contentsCopy[index] as? NumberToken {
                if number.digit < 0 {
                    var mutableNumber = number
                    mutableNumber.digit = abs(mutableNumber.digit)
                    contentsCopy[index] = mutableNumber
                    contentsCopy.insert(LinearOperationToken(operation: .minus), at: index)
                }
            }
        }
    }
}
