//
//  Queen.swift
//  Chess
//
//  Created by Aidan Lee on 1/8/22.
//

import Foundation

class Queen: RecursivePiece {
    
    var hasMoved = false
        
    let type = PieceType.queen
    
    let side: Game.Side
    
    let moveType: MoveType = .both
    
    init(_ side: Game.Side) {
        self.side = side
    }
    
}
