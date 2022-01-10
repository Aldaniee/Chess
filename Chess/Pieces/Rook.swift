//
//  Rook.swift
//  Chess
//
//  Created by Aidan Lee on 1/6/22.
//

import Foundation

struct Rook: RecursivePiece {
        
    var hasMoved = false
    
    let num: Int
    
    let type = Game.PieceType.rook
    
    let side: Game.Side
    
    let moveType: MoveType = .verticalHorizontal
    
    init(side: Game.Side, num: Int) {
        self.side = side
        self.num = num
    }

}
