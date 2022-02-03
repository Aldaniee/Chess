//
//  UtilityExtensions.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

extension Int {
    func toLetterAtAlphabeticalIndex() -> Character {
        let startingValue = Int(("a" as UnicodeScalar).value)
        return Character(UnicodeScalar(self + startingValue) ?? UnicodeScalar(0))
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    func toAlphabeticalIndex() -> Int {
        let startingValue = Int(("a" as UnicodeScalar).value)
        let currentValue = Int((Unicode.Scalar(String(self)))?.value ?? UInt32(startingValue))
        return currentValue - startingValue
    }
}
