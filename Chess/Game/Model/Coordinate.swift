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

struct Coordinate: Hashable {
    
    let rankIndex: Int // 0-7
    let fileIndex: Int // 0-7
    
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
    
    // MARK: - Initializers
    
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
    
    // MARK: - Accessors
    func upRank() -> Coordinate? {
        return rankIndex < 7 ? Coordinate(rankIndex+1, fileIndex) : nil
    }
    func downRank() -> Coordinate? {
        return rankIndex > 0 ? Coordinate(rankIndex-1, fileIndex) : nil
    }
    func upFile() -> Coordinate? {
        return fileIndex < 7 ? Coordinate(rankIndex, fileIndex+1) : nil
    }
    func downFile() -> Coordinate? {
        return fileIndex > 0 ? Coordinate(rankIndex, fileIndex-1) : nil
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
        var coordinates = [Coordinate]()
        coordinates.append(Direction.upRankUpFile.compute(self))
        coordinates.append(Direction.upRankDownFile.compute(self))
        return coordinates
    }
    func downOneDiagonals() -> [Coordinate] {
        var coordinates = [Coordinate]()
        coordinates.append(Direction.downRankUpFile.compute(self))
        coordinates.append(Direction.downRankDownFile.compute(self))
        return coordinates
    }
    func sameFile() -> [Coordinate] {
        return allCoords(in: [.upRank, .downRank])
    }
    func sameRank() -> [Coordinate] {
        return allCoords(in: [.upFile, .downFile])
    }
    func sameDiagonal() -> [Coordinate] {
        return allCoords(in: [.upRankUpFile, .upRankDownFile, .downRankUpFile, .downRankDownFile])
    }
    
    /// Return all coords in a given direction that are still on the board
    /// - Parameters:
    ///   - direction: Direction in which to enumerate
    /// - Returns: Array of all coordinates in that direction (not including self)
    func allCoords(in direction: Direction) -> [Coordinate] {
        var coords = [Coordinate]()
        var next = direction.compute(self)
        while next != nil {
            coords.append(next!)
            next = direction.compute(next!)
        }
        return coords
    }
    
    func oneCoordinate(inEach directions: [Direction]) -> [Coordinate] {
        var coords = [Coordinate]()
        
        directions.forEach { direction in
            coords.append(direction.compute(self))
        }
        return coords
    }
    
    func allCoords(in directions: [Direction]) -> [Coordinate] {
        var coords = [Coordinate]()
        
        directions.forEach { direction in
            coords.append(contentsOf: allCoords(in: direction))
        }
        return coords
    }
    
    // MARK: - Relations
    // used to determine if castling
    func distance(to coordinate: Coordinate) -> Int {
        return abs(coordinate.rankIndex-self.rankIndex) + abs(coordinate.fileIndex-self.fileIndex)
    }
    // used to determine if en passant
    func isDiagonal(from end: Coordinate) -> Bool {
        return self.sameDiagonal().contains(end)
    }
}

extension Coordinate {

    enum Direction {
        static var all: [Direction] = diagonals + verticalHorizontals
        static var diagonals: [Direction] = [.upRankUpFile, .upRankDownFile, .downRankUpFile, .downRankDownFile]
        static var verticalHorizontals: [Direction] = [.upRank, .downRank, .upFile, .downFile]
        
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
        
        var opposite: Direction {
            switch self {
            case .upRank:
                return .downRank
            case .downRank:
                return .upRank
            case .upFile:
                return .downFile
            case .downFile:
                return .upFile
            case .upRankUpFile:
                return .downRankDownFile
            case .upRankDownFile:
                return .downRankUpFile
            case .downRankUpFile:
                return .upRankDownFile
            case .downRankDownFile:
                return .upRankUpFile
            }
        }
    }
}
