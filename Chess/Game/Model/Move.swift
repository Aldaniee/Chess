//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

struct FullMove {
    var white: Move
    var black: Move?
}

struct Move : Equatable {
    
    var start: Coordinate
    
    var end: Coordinate
    
    var piece: Piece
    
    var capturedPiece: Piece?
    
    var isCastling: Bool
    
    var promotesTo: Piece?
    
    var isReversible: Bool
        
    init(_ game: Game, from start: Coordinate, to end: Coordinate, promotesTo: Piece? = nil) {
        self.start = start
        self.end = end
        self.piece = game.getPiece(from: start)!
        self.capturedPiece = game.getPiece(from: end)
        self.isCastling = piece.type == .king && start.distance(to: end) != 1
        self.isReversible = !(piece.type == .pawn || isCastling)
        self.promotesTo = promotesTo
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
