//
//  Bishop.swift
//  Chess
//
//  Created by Aidan Lee on 1/7/22.
//

import Foundation

class Bishop: RecursivePiece {
    
    var hasMoved = false
    
    let num: Int
    
    let type = Game.PieceType.bishop
    
    let side: Game.Side
    
    let moveType: MoveType = .diagonal
    
    init(side: Game.Side, num: Int) {
        self.side = side
        self.num = num
    }
        
}
