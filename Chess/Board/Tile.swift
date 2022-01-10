//
//  Tile.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Tile: Identifiable {
    
    var id: String {
        return "\(coordinate.fileLetter)\(coordinate.rankNum)"
    }
    let coordinate: Coordinate
    
    var piece: Piece?
    
    var display: TileColor {
        return ((coordinate.fileIndex + coordinate.rankIndex) % 2 == 0) ? TileColor.dark : TileColor.light
    }
    
    init(_ coordinate: Coordinate, _ piece: Piece? = nil) {
        self.coordinate = coordinate
        self.piece = piece
    }
    
    enum TileColor {
        case dark
        case light
        
        var color: Color {
            switch self {
            case .light:
                return .white
            case .dark:
                return .black
            }
        }
        var inverseColor: Color {
            switch self {
            case .light:
                return .black
            case .dark:
                return .white
            }
        }
    }

}
