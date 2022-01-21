//
//  Queen.swift
//  Chess
//
//  Created by Aidan Lee on 1/8/22.
//

import Foundation

class Queen: RecursivePiece {
    
    let id = UUID().hashValue
    
    var hasMoved = false
        
    let type = PieceType.queen
    
    let side: Side
    
    let moveType: MoveType = .both
    
    init(_ side: Side) {
        self.side = side
    }
    
}