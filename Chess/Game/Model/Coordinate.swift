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

struct Coordinate: Equatable, Hashable {

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
    
    // MARK: - Single Related Coordinate
    func upRank() -> Coordinate? {
        if rankIndex < 7 {
            return Coordinate(rankIndex+1, fileIndex)
        }
        return nil
    }
    func downRank() -> Coordinate? {
        if rankIndex > 0 {
            return Coordinate(rankIndex-1, fileIndex)
        }
        return nil
    }
    func upFile() -> Coordinate? {
        if fileIndex < 7 {
            return Coordinate(rankIndex, fileIndex+1)
        }
        return nil
    }
    func downFile() -> Coordinate? {
        if fileIndex > 0 {
            return Coordinate(rankIndex, fileIndex-1)
        }
        return nil
    }
    func upRankUpFile() -> Coordinate? {
        return self.upRank()?.upFile()
    }
    func upRankDownFile() -> Coordinate? {
        return self.upRank()?.downFile()
    }
    func downRankUpFile() -> Coordinate? {
        return self.downRank()?.upFile()
    }
    func downRankDownFile() -> Coordinate? {
        return self.downRank()?.downFile()
    }
    
    // MARK: - Multiple Related Coordinates
    func upOneDiagonals() -> [Coordinate] {
        var coords = [Coordinate]()
        if let upUpDiagonal = upRankUpFile() {
            coords.append(upUpDiagonal)
        }
        if let upDownDiagonal = upRankDownFile() {
            coords.append(upDownDiagonal)
        }
        return coords
    }
    func downOneDiagonals() -> [Coordinate] {
        var coords = [Coordinate]()
        
        if let downUpDiagonal = downRankUpFile() {
            coords.append(downUpDiagonal)
        }
        if let downDownDiagonal = downRankDownFile() {
            coords.append(downDownDiagonal)
        }
        return coords
    }
}

extension Coordinate {
    // Expect Values ('A'-'H', 1-8)
    init(fileLetter: Character, rankNum: Int) {
        self.init(rankNum - 1, fileLetter.lowercased().toAlphabeticalIndex())
    }
    
    // Expect Values ("A1" - "H8")
    init(notation: String) {
        let fileLetter = notation[0]
        
        if let rankNum = notation[1].wholeNumberValue {
            self.init(fileLetter: fileLetter, rankNum: rankNum)
        }
        else {
            print("ERROR: \(CoordinateError.integerParsingError)")
            self.init(0, 0)
        }
    }
    
    enum Direction {
        case upRank
        case downRank
        case upFile
        case downFile
        case upRankUpFile
        case upRankDownFile
        case downRankUpFile
        case downRankDownFile
        
        var compute: ((Coordinate) -> Coordinate?) {
            switch self {
            case .upRank:
                return { (c: Coordinate) -> Coordinate? in c.upRank() }
            case .downRank:
                return { (c: Coordinate) -> Coordinate? in c.downRank() }
            case .upFile:
                return { (c: Coordinate) -> Coordinate? in c.upFile() }
            case .downFile:
                return { (c: Coordinate) -> Coordinate? in c.downFile() }
            case .upRankUpFile:
                return { (c: Coordinate) -> Coordinate? in c.upRankUpFile() }
            case .upRankDownFile:
                return { (c: Coordinate) -> Coordinate? in c.upRankDownFile() }
            case .downRankUpFile:
                return { (c: Coordinate) -> Coordinate? in c.downRankUpFile() }
            case .downRankDownFile:
                return { (c: Coordinate) -> Coordinate? in c.downRankDownFile() }
            }
        }
    }
}
