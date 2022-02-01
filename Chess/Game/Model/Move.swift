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
    
    var display: String {
        "\(white.pgnNotation) \(black?.pgnNotation ?? "") "
    }
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
        let isEnPassant = piece.type == .pawn && start.isDiagonal(from: end) && capturedPiece == nil
        if capturedPiece != nil || isEnPassant { notation.append("x") }
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
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
