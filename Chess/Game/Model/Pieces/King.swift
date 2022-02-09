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
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        var potentialEnd = [Coordinate]()
        potentialEnd.append(start.upFile())
        potentialEnd.append(start.downFile())
        potentialEnd.append(start.upRank())
        potentialEnd.append(start.downRank())
        potentialEnd.append(start.upRankUpFile())
        potentialEnd.append(start.upRankDownFile())
        potentialEnd.append(start.downRankUpFile())
        potentialEnd.append(start.downRankDownFile())
        
        var moves = [Move]()
        potentialEnd.forEach { end in
            moves.append(Move(game, from: start, to: end))
        }
        return moves
    }
}
