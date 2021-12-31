//
//  UtilityExtensions.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation
import SwiftUI

extension GeometryProxy {
    func minWidthHeight() -> CGFloat {
        return min(self.size.width, self.size.height)
    }
}

extension Int {
    func toLetterAtAlphabeticalIndex() -> Character {
        let startingValue = Int(("A" as UnicodeScalar).value)
        return Character(UnicodeScalar(self + startingValue) ?? UnicodeScalar(0))
    }
}

extension Character {
    func alphabeticalIndex() -> Int {
        let startingValue: Int = Int(("A" as UnicodeScalar).value)
        let currentValue = Int((Unicode.Scalar(String(self)))?.value ?? UInt32(startingValue))
        return currentValue - startingValue
    }
}
