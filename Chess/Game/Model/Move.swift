//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

struct Move : Equatable {
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
    var start: Coordinate
    var end: Coordinate
    var piece: Piece
    var capturedPiece: Piece?
    var isReversible: Bool
    var promotesTo: Piece?
    
    init(_ game: Game, from start: Coordinate, to end: Coordinate, promotesTo: Piece? = nil) {
        self.start = start
        self.end = end
        let piece = game.getPiece(from: start)!
        self.piece = piece
        self.capturedPiece = game.getPiece(from: end)
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
        if capturedPiece != nil { notation.append("x") }
        notation.append(end.algebraicNotation)
        if let promotesTo = promotesTo {
            notation.append("=\(promotesTo.type.rawValue)")
        }
//        if checkmatesOpponent {
//            notation.append("#")
//        }
//        else if checksOpponent {
//            notation.append("+")
//        }
        return notation
    }
    
}
