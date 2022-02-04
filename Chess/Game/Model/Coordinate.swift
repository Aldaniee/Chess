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
    
    // MARK: - Single Related Coordinate
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
    func sameFile() -> [Coordinate] {
        var coords = [Coordinate]()
        for rank in 0..<8 {
            if rank != rankIndex {
                coords.append(Coordinate(rank, fileIndex))
            }
        }
        return coords
    }
    func sameRank() -> [Coordinate] {
        var coords = [Coordinate]()
        for file in 0..<8 {
            if file != fileIndex {
                coords.append(Coordinate(rankIndex, file))
            }
        }
        return coords
    }
    func sameDiagonal() -> [Coordinate] {
        var coords = [Coordinate]()
        
        coords.append(contentsOf: allCoords(in: .upRankUpFile))
        coords.append(contentsOf: allCoords(in: .upRankDownFile))
        coords.append(contentsOf: allCoords(in: .downRankUpFile))
        coords.append(contentsOf: allCoords(in: .downRankDownFile))
        
        return coords
    }
    /// Coords between self coordiante and given coordinate horizontally
    /// - Parameter end: Second coordinate to use
    /// - Returns: Array of coordinate between the two coordinates (empty if coordiantes are the same, adjacent, or not on the same rank
    func horizontalCoordsBetween(to end: Coordinate) -> [Coordinate] {
        if self.isHorizontal(from: end){
            if fileIndex < end.fileIndex {
                return coordsBetween(to: end, in: .upFile)
            }
            if fileIndex > end.fileIndex {
                return coordsBetween(to: end, in: .downFile)
            }
        }
        return [Coordinate]()
    }
    
    /// Coords between self coordiante and given coordinate in given direction
    /// - Parameters:
    ///   - end: Second coordinate to use
    ///   - direction: Direction of second coordinate from first
    /// - Returns: Array of coordinate between the two coordinates
    private func coordsBetween(to end: Coordinate, in direction: Direction) -> [Coordinate] {
        var between = [Coordinate]()
        
        var next = direction.compute(self)
        while next != nil && next! != end {
            between.append(next!)
            next = direction.compute(self)
        }
        return between
    }
    
    /// Return all coords in a given direction
    /// - Parameters:
    ///   - direction: Direction in which to enumerate
    /// - Returns: Array of all coordinates in that direction (not including self)
    func allCoords(in direction: Direction) -> [Coordinate] {
        var moves = [Coordinate]()
        
        var next = direction.compute(self)
        while next != nil {
            moves.append(next!)
            next = direction.compute(next!)
        }
        return moves
    }
    
    // MARK: - Relations
    func distance(to coordinate: Coordinate) -> Int {
        return abs(coordinate.rankIndex-self.rankIndex) + abs(coordinate.fileIndex-self.fileIndex)
    }
    
    func isDiagonal(from end: Coordinate) -> Bool {
        return self.sameDiagonal().contains(end)
    }
    func isHorizontal(from end: Coordinate) -> Bool {
        return self.rankIndex == end.rankIndex
    }
    func isVertical(from end: Coordinate) -> Bool {
        return self.fileIndex == end.fileIndex
    }
    func isValid() -> Bool {
        return rankIndex < 8 && fileIndex < 8 && fileIndex > -1 && rankIndex > -1
    }
}

extension Coordinate {

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
