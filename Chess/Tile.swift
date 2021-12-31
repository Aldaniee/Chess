//
//  Tile.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation
import SwiftUI

struct Tile: Identifiable {
    
    var id: String {
        return "\(coordinate.rankNum)\(coordinate.fileLetter)"
    }
    let coordinate: Coordinate
    
    var piece: Piece?
    
    var color: Color {
        return ((coordinate.fileIndex + coordinate.rankIndex) % 2 == 0) ? TileColor.dark.color : TileColor.light.color
    }
    
    func coordinateToNotation(coordinate: Coordinate) -> (Character, Int) {
        return ((coordinate.fileIndex).toLetterAtAlphabeticalIndex(), coordinate.rankIndex + 1)
    }
    
    init(coordinate: Coordinate, piece: Piece? = nil) {
        self.coordinate = coordinate
        self.piece = piece
    }
    
    enum TileColor {
        case dark
        case light
        var color: Color {
            switch self {
            case .light:
                return Color.white
            case .dark:
                return Color.black
            }
        }
    }

}

struct Coordinate: Equatable {
    
    init(rankIndex: Int, fileIndex: Int) {
        self.rankIndex = rankIndex
        self.fileIndex = fileIndex
    }
    init(fileLetter: Character, rankNum: Int) {
        self.rankIndex = rankNum - 1
        self.fileIndex = fileLetter.alphabeticalIndex()
    }
    let rankIndex: Int
    let fileIndex: Int
    var rankNum: Int {
        return rankIndex + 1
    }
    var fileLetter: Character {
        return fileIndex.toLetterAtAlphabeticalIndex()
    }
}
