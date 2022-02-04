//
//  King.swift
//  Chess
//
//  Created by Aidan Lee on 1/5/22.
//

import Foundation

struct King: Piece {
            
    let type = PieceType.king
    
    let side: Side
        
    init(_ side: Side) {
        self.side = side
    }
}
