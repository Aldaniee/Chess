//
//  UtilityExtensions.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation
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

extension Array where Element == (piece: Piece, count: Int) {

    mutating func appendAndSort(piece: Piece) -> [(piece: Piece, count: Int)] {
        if let index = self.firstIndex(where: {$0.piece.type == piece.type}) {
            self[index].count += 1
        }
        else {
            self.append((piece, 1))
        }
        return self.sorted { p1, p2 in
            p1.piece.points == p2.piece.points ? p1.piece.type.abbreviation > p2.piece.type.abbreviation : p1.piece.points < p2.piece.points
        }
    }
    
}
