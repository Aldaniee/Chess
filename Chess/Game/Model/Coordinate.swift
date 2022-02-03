//
//  Coordinate.swift
//  Chess
//
//  Created by Aidan Lee on 12/31/21.
//

import Foundation

enum CoordinateError: Error {
    case rankOutOfBounds, fileOutOfBounds, integerParsingError
}

struct Coordinate {
    
    let rankIndex: Int // 0-7
    let fileIndex: Int // 0-7
    
    // Expect Values (0-7, 0-7)
    init(_ rankIndex: Int, _ fileIndex: Int) {
        if !(0...7).contains(rankIndex) {
            print("ERROR: \(CoordinateError.rankOutOfBounds)")
        }
        if !(0...7).contains(fileIndex) {
            print("ERROR: \(CoordinateError.fileOutOfBounds)")
        }
        self.rankIndex = rankIndex
        self.fileIndex = fileIndex
    }
    
    // 1-8
    var rankNum: Int {
        rankIndex + 1
    }
    
    // A-H
    var fileLetter: Character {
        fileIndex.toLetterAtAlphabeticalIndex()
    }
    
    // A1-H8
    var notation: String {
        "\(fileLetter)\(rankNum)"
    }
}

extension Coordinate {
    
    // Expect Values (A-H, 1-8)
    init(fileLetter: Character, rankNum: Int) {
        self.init(rankNum - 1, fileLetter.lowercased().toAlphabeticalIndex())
    }
    
    // Expect Values (A1-H8)
    init(notation: String) {
        let fileLetter = notation[0]
        if let rankNum = notation[1].wholeNumberValue {
            self.init(fileLetter: fileLetter, rankNum: rankNum)
        } else {
            print("ERROR: \(CoordinateError.integerParsingError)")
            self.init(0, 0)
        }
    }
}
