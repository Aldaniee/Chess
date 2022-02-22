//
//  King.swift
//  Chess
//
//  Created by Aidan Lee on 1/5/22.
//

import Foundation

struct King: Piece {
    
    let id = UUID().hashValue
        
    let type = PieceType.king
    
    let side: Side
    
    let points = 4
    
    init(_ side: Side) {
        self.side = side
    }
        
    // MARK: - Piece Protocol Functions
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        var threats = [Coordinate]()
        threats.append(start.upRank())
        threats.append(start.upFile())
        threats.append(start.downRank())
        threats.append(start.downFile())
        threats.append(start.upRankUpFile())
        threats.append(start.upRankDownFile())
        threats.append(start.downRankUpFile())
        threats.append(start.downRankDownFile())
        return threats
    }
    
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        possibleMovesFromThreats(from: start, game)
    }
}
