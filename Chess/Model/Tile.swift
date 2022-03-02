//
//  Tile.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Tile: Identifiable {
    
    let id = UUID()
    
    let coordinate: Coordinate
    var piece: Piece?
    
    var color: Color {
        (coordinate.fileIndex + coordinate.rankIndex).isMultiple(of: 2) ? .black : .white
    }
    
    init(_ coordinate: Coordinate, _ piece: Piece? = nil) {
        self.coordinate = coordinate
        self.piece = piece
    }

}
