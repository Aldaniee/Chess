//
//  Queen.swift
//  Chess
//
//  Created by Aidan Lee on 1/8/22.
//

import Foundation

class Queen: RecursivePiece {
    
    var hasMoved = false
    
    let num: Int
    
    let type = Game.PieceType.queen
    
    let side: Game.Side
    
    let moveType: MoveType = .both
    
    init(side: Game.Side, num: Int) {
        self.side = side
        self.num = num
    }
    
}
