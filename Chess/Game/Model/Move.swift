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
    var isCheckmate: Bool
    var isReversible: Bool
    var promotesTo: Piece?
    
    init(from start: Coordinate, to end: Coordinate, with piece: Piece, capturing capturedPiece: Piece? = nil, withCheck isCheck: Bool = false, withCheckmate isCheckmate: Bool = false, promotesTo: Piece? = nil) {
        self.start = start
        self.end = end
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.isCheck = isCheck
        self.isCheckmate = isCheckmate
        let isCastling = piece.type == .king && start.distance(to: end) != 1
        self.isReversible = piece.type != .pawn && !isCastling
        self.promotesTo = promotesTo
    }
    
    var pgnNotation: String {
        var notation = ""
        
        switch piece.type {
        case .king:
            let distance = start.distance(to: end)
            if distance == 2 {
                notation = "O-O"
            }
            else if distance == 3 {
                notation = "O-O-O"
            }
        case .pawn:
            notation = ""
        default:
            notation = piece.type.rawValue
        }
        if capturedPiece != nil { notation.append("x")}
        notation.append(end.algebraicNotation)
        if let promotesTo = promotesTo {
            notation.append("=\(promotesTo.type.rawValue)")
        }
        if isCheckmate {
            notation.append("#")
        }
        else if isCheck {
            notation.append("+")
        }
        return notation
    }
    
}
