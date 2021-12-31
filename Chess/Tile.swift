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
