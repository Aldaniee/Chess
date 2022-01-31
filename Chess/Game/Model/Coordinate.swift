//
//  Coordinate.swift
//  Chess
//
//  Created by Aidan Lee on 12/31/21.
//

import Foundation

struct Coordinate: Equatable, Hashable {
        
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
    
    init(rankIndex: Int, fileIndex: Int) {
        self.rankIndex = rankIndex
        self.fileIndex = fileIndex
    }
    init(fileLetter: Character, rankNum: Int) {
        self.rankIndex = rankNum - 1
        self.fileIndex = fileLetter.lowercased().alphabeticalIndex()
    }
    init(algebraicNotation: String) {
        let fileLetter = algebraicNotation[0]
        self.fileIndex = fileLetter.lowercased().alphabeticalIndex()
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
    
    // MARK: - Single Related Coordinate
    func upRank() -> Coordinate? {
        if rankIndex < 7 {
            return Coordinate(rankIndex: rankIndex+1, fileIndex: fileIndex)
        }
        return nil
    }
    func downRank() -> Coordinate? {
        if rankIndex > 0 {
            return Coordinate(rankIndex: rankIndex-1, fileIndex: fileIndex)
        }
        return nil
    }
    func upFile() -> Coordinate? {
        if fileIndex < 7 {
            return Coordinate(rankIndex: rankIndex, fileIndex: fileIndex+1)
        }
        return nil
    }
    func downFile() -> Coordinate? {
        if fileIndex > 0 {
            return Coordinate(rankIndex: rankIndex, fileIndex: fileIndex-1)
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
    func sameFile() -> [Coordinate] {
        var coords = [Coordinate]()
        for rank in 0..<8 {
            if rank != rankIndex {
                coords.append(Coordinate(rankIndex: rank, fileIndex: fileIndex))
            }
        }
        return coords
    }
    func sameRank() -> [Coordinate] {
        var coords = [Coordinate]()
        for file in 0..<8 {
            if file != fileIndex {
                coords.append(Coordinate(rankIndex: rankIndex, fileIndex: file))
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
