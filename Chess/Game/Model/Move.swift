//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

enum MoveError: Error {
    case invalidPiece
}

struct Move : Equatable {
    
    var start: Coordinate
    
    var end: Coordinate
    
    var piece: Piece
            
    init(_ game: Game, from start: Coordinate, to end: Coordinate) {
        self.start = start
        self.end = end
        self.piece = game.getPiece(from: start)!
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
