//
//  Bishop.swift
//  Chess
//
//  Created by Aidan Lee on 1/7/22.
//

import Foundation

class Bishop: RecursivePiece {
    
    var hasMoved = false
        
    let type = Game.PieceType.bishop
    
    let side: Game.Side
    
    let moveType: MoveType = .diagonal
    
    init(_ side: Game.Side) {
        self.side = side
    }
        
}
