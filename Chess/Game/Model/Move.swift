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
    var piece: PieceType
    var capturedPiece: PieceType?
    var isCheck: Bool
    
    init(from start: Coordinate, to end: Coordinate, with piece: PieceType, capturing capturedPiece: PieceType? = nil, withCheck isCheck: Bool = false) {
        self.start = start
        self.end = end
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.isCheck = isCheck
    }
    
    var fullAlgebraicNotation: String {
        var notation = piece != .pawn ? "\(piece.rawValue)" : ""
        if capturedPiece != nil { notation.append("x")}
        notation.append(end.algebraicNotation)
        if isCheck { notation.append("+")}
        return notation
    }
    
}
