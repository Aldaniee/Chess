//
//  Queen.swift
//  Chess
//
//  Created by Aidan Lee on 1/8/22.
//

import Foundation

class Queen: RecursivePiece {
    
    let id = UUID().hashValue
            
    let type = PieceType.queen
    
    let side: Side
    
    let points = 9
    
    let moveDirections = Coordinate.Direction.all
    
    init(_ side: Side) {
        self.side = side
    }
    
}
