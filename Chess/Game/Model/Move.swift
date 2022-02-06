//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

struct Move: Equatable {
    
    var start: Coordinate
    
    var end: Coordinate
    
    var piece: Piece
    
    var capturedPiece: Piece?
        
    init(_ game: Game, from start: Coordinate, to end: Coordinate, promotesTo: Piece? = nil) {
        self.start = start
        self.end = end
        self.piece = game.getPiece(from: start)!
        self.capturedPiece = game.getPiece(from: end)
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
