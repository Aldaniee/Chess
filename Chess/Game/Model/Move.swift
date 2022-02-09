//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

struct Move : Equatable {
    
    var start: Coordinate
    
    var end: Coordinate
    
    var piece: Piece
            
    init(_ piece: Piece, from start: Coordinate, to end: Coordinate) {
        self.start = start
        self.end = end
        self.piece = piece
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
