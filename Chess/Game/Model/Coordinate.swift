//
//  Coordinate.swift
//  Chess
//
//  Created by Aidan Lee on 12/31/21.
//

import Foundation

struct Coordinate: Hashable {
    
    init(rankIndex: Int, fileIndex: Int) {
        self.rankIndex = rankIndex
        self.fileIndex = fileIndex
    }
    init(fileLetter: Character, rankNum: Int) {
        self.rankIndex = rankNum - 1
        self.fileIndex = fileLetter.lowercased().toAlphabeticalIndex()
    }
    init(algebraicNotation: String) {
        let fileLetter = algebraicNotation[0]
        self.fileIndex = fileLetter.lowercased().toAlphabeticalIndex()
        guard let rankNum = algebraicNotation[1].wholeNumberValue else {
            print("ERROR: incorrect second character")
            rankIndex = -1
            return
        }
        self.rankIndex = rankNum - 1
    }
    var rankIndex: Int
    var fileIndex: Int
    
    var rankNum: Int {
        return rankIndex + 1
    }
    var fileLetter: Character {
        return fileIndex.toLetterAtAlphabeticalIndex()
    }
    var algebraicNotation: String {
        return "\(fileLetter.lowercased())\(rankNum)"
    }
}
