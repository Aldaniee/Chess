//
//  Bishop.swift
//  Chess
//
//  Created by Aidan Lee on 1/7/22.
//

import Foundation

class Bishop: RecursivePiece {
    
    let id = UUID().hashValue
            
    let type = PieceType.bishop
    
    let side: Side
    
    let moveType: MoveType = .diagonal
    
    init(_ side: Side) {
        self.side = side
    }
        
}
