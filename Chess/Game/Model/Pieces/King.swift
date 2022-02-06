//
//  King.swift
//  Chess
//
//  Created by Aidan Lee on 1/5/22.
//

import Foundation

struct King: Piece {
            
    let type = PieceType.king
    
    let side: Side
    
    init(_ side: Side) {
        self.side = side
    }
    
    // MARK: - Piece Protocol Functions
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        var moves = [Coordinate]()
        moves.append(start.upRank())
        moves.append(start.downRank())
        moves.append(start.upFile())
        moves.append(start.downFile())
        moves.append(start.upRankDownFile())
        moves.append(start.downRankDownFile())
        moves.append(start.upRankUpFile())
        moves.append(start.downRankUpFile())
        return moves
    }
    
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        // TODO: Add Castling
        return self.possibleMovesFromThreats(from: start, game)
    }
}
