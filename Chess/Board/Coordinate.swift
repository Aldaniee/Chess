//
//  Coordinate.swift
//  Chess
//
//  Created by Aidan Lee on 12/31/21.
//

import Foundation

struct Coordinate: Equatable, Hashable {
    
    init(rankIndex: Int, fileIndex: Int) {
        self.rankIndex = rankIndex
        self.fileIndex = fileIndex
    }
    init(fileLetter: Character, rankNum: Int) {
        self.rankIndex = rankNum - 1
        self.fileIndex = fileLetter.alphabeticalIndex()
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
    
    func debugPrint() {
        print("\(fileLetter)\(rankNum)", separator: "")
    }
    
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

    func upOneDiagonals() -> [Coordinate] {
        var coords = [Coordinate]()
        if let upLeft = self.upRank()?.downFile() {
            coords.append(upLeft)
        }
        if let upRight = self.upRank()?.upFile() {
            coords.append(upRight)
        }
        return coords
    }
    func downOneDiagonals() -> [Coordinate] {
        var coords = [Coordinate]()
        if let downLeft = self.downRank()?.downFile() {
            coords.append(downLeft)
        }
        if let downRight = self.downRank()?.upFile() {
            coords.append(downRight)
        }
        return coords
    }
    
    func sameFile() -> [Coordinate] {
        var coords = [Coordinate]()
        for rank in 0..<Board.Constants.dimensions {
            if rank != rankIndex {
                coords.append(Coordinate(rankIndex: rank, fileIndex: fileIndex))
            }
        }
        return coords
    }
    func sameRank() -> [Coordinate] {
        var coords = [Coordinate]()
        for file in 0..<Board.Constants.dimensions {
            if file != fileIndex {
                coords.append(Coordinate(rankIndex: rankIndex, fileIndex: file))
            }
        }
        return coords
    }
    func sameDiagonal() -> [Coordinate] {
        var coords = [Coordinate]()
        
        var i = 1
        var coord = Coordinate(rankIndex: rankIndex+i, fileIndex: fileIndex+i)
        while coord.isValid() {
            coords.append(coord)
            i += 1
            coord = Coordinate(rankIndex: rankIndex+i, fileIndex: fileIndex+i)
        }
        i = 1
        coord = Coordinate(rankIndex: rankIndex-i, fileIndex: fileIndex-i)
        while coord.isValid() {
            coords.append(coord)
            i += 1
            coord = Coordinate(rankIndex: rankIndex-i, fileIndex: fileIndex-i)
        }
        
        i = 1
        coord = Coordinate(rankIndex: rankIndex-i, fileIndex: fileIndex+i)
        while coord.isValid() {
            coords.append(coord)
            i += 1
            coord = Coordinate(rankIndex: rankIndex-i, fileIndex: fileIndex+i)
        }
        i = 1
        coord = Coordinate(rankIndex: rankIndex+i, fileIndex: fileIndex-i)
        while coord.isValid() {
            coords.append(coord)
            i += 1
            coord = Coordinate(rankIndex: rankIndex+i, fileIndex: fileIndex-i)
        }
        return coords
    }
    func isDiagonal(from end: Coordinate) -> Bool {
        return self.sameDiagonal().contains(end)
    }
    func isValid() -> Bool {
        return rankIndex < Board.Constants.dimensions && fileIndex < Board.Constants.dimensions && fileIndex > -1 && rankIndex > -1
    }
}
