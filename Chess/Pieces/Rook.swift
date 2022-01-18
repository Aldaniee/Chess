//
//  Rook.swift
//  Chess
//
//  Created by Aidan Lee on 1/6/22.
//

import Foundation

struct Rook: RecursivePiece {
    
    let id = UUID().hashValue
    
    var hasMoved = false
        
    let type = PieceType.rook
    
    let side: Side
    
    let moveType: MoveType = .verticalHorizontal
    
    init(_ side: Side) {
        self.side = side
    }

}
