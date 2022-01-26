//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

struct Move {
    var start: Coordinate
    var end: Coordinate
    var piece: Piece
    var capturedPiece: Piece?
    var isCheck: Bool
    var isReversible: Bool
    
    init(from start: Coordinate, to end: Coordinate, with piece: Piece, capturing capturedPiece: Piece? = nil, withCheck isCheck: Bool = false, isReversible: Bool) {
        self.start = start
        self.end = end
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.isCheck = isCheck
        self.isReversible = isReversible
    }
    
    var fullAlgebraicNotation: String {
        var notation = piece.type != .pawn ? "\(piece.type.rawValue)" : ""
        if capturedPiece != nil { notation.append("x")}
        notation.append(end.algebraicNotation)
        if isCheck { notation.append("+")}
        return notation
    }
    
}
