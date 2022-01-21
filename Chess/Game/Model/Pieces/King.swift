//
//  King.swift
//  Chess
//
//  Created by Aidan Lee on 1/5/22.
//

import Foundation

struct King: Piece {
    
    let id = UUID().hashValue

    var hasMoved = false
        
    let type = PieceType.king
    
    let side: Side
    
    init(_ side: Side) {
        self.side = side
    }
    
    func threatsCreated(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        
        if let upRank = start.upRank() {
            moves.append(upRank)
        }
        if let downRank = start.downRank() {
            moves.append(downRank)
        }
        if let upFile = start.upFile() {
            moves.append(upFile)
        }
        if let downFile = start.downFile() {
            moves.append(downFile)
        }
        moves.append(contentsOf: start.upOneDiagonals())
        moves.append(contentsOf: start.downOneDiagonals())
        
        return moves
    }
    
    func allPossibleMoves(from start: Coordinate, _ board: Board) -> [Coordinate] {
        self.getMovesFromThreats(from: start, board)
    }
}