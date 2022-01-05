//
//  King.swift
//  Chess
//
//  Created by Aidan Lee on 1/5/22.
//

import Foundation

struct King: Piece {
    
    let type = Game.PieceType.king
    
    let side: Game.Side
    
    init(side: Game.Side) {
        self.side = side
    }
    
    func allPossibleMoves(from start: Coordinate, board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        
        if let upRank = start.upRank() {
            if !board.isOccupied(upRank, side) {
                moves.append(upRank)
            }
        }
        if let downRank = start.downRank() {
            if !board.isOccupied(downRank, side) {
                moves.append(downRank)
            }
        }
        if let upFile = start.upFile() {
            if !board.isOccupied(upFile, side) {
                moves.append(upFile)
            }
        }
        if let downFile = start.downFile() {
            if !board.isOccupied(downFile, side) {
                moves.append(downFile)
            }
        }
        start.upOneDiagonals().forEach({ move in
            if !board.isOccupied(move, side) {
                moves.append(move)
            }
        })
        start.downOneDiagonals().forEach({ move in
            if !board.isOccupied(move, side) {
                moves.append(move)
            }
        })
        
        return moves
    }
}
