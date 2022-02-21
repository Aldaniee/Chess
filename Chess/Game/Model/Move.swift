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
    
    init(_ game: Game, from start: Coordinate, to end: Coordinate) {
        self.start = start
        self.end = end
        let piece = game.getPiece(start)!
        self.piece = piece
        self.capturedPiece = game.getPiece(end)
    }
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}
