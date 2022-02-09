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
    func possibleMoves(from start: Coordinate) -> [Move] {
        var ends = [Coordinate]()
        ends.append(start.upFile())
        ends.append(start.downFile())
        ends.append(start.upRank())
        ends.append(start.downRank())
        ends.append(start.upRankUpFile())
        ends.append(start.upRankDownFile())
        ends.append(start.downRankUpFile())
        ends.append(start.downRankDownFile())
        
        var moves = [Move]()
        ends.forEach { end in
            moves.append(Move(self, from: start, to: end))
        }
        return moves
    }
}
