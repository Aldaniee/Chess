//
//  Rook.swift
//  Chess
//
//  Created by Aidan Lee on 1/6/22.
//

import Foundation

struct Rook: RecursivePiece {
        
    var hasMoved = false
        
    let type = Game.PieceType.rook
    
    let side: Game.Side
    
    let moveType: MoveType = .verticalHorizontal
    
    init(_ side: Game.Side) {
        self.side = side
    }

}
