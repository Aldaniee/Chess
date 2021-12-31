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
    
    func debugPrint() {
        print("\(fileLetter)\(rankNum)", separator: "")
    }
    
    func upRank() -> Coordinate {
        return Coordinate(rankIndex: rankIndex+1, fileIndex: fileIndex)
    }
    func upOneDiagonals() -> [Coordinate] {
        var coords = [Coordinate]()
        coords.append(Coordinate(rankIndex: rankIndex+1, fileIndex: fileIndex-1))
        coords.append(Coordinate(rankIndex: rankIndex+1, fileIndex: fileIndex+1))
        return coords
    }
    func downOneDiagonals() -> [Coordinate] {
        var coords = [Coordinate]()
        coords.append(Coordinate(rankIndex: rankIndex-1, fileIndex: fileIndex-1))
        coords.append(Coordinate(rankIndex: rankIndex-1, fileIndex: fileIndex+1))
        return coords
    }
    func downRank() -> Coordinate {
        return Coordinate(rankIndex: rankIndex-1, fileIndex: fileIndex)
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
    func isValid() -> Bool {
        return rankIndex < Board.Constants.dimensions && fileIndex < Board.Constants.dimensions && fileIndex > -1 && rankIndex > -1
    }
}
