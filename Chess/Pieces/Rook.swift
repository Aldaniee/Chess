//
//  Rook.swift
//  Chess
//
//  Created by Aidan Lee on 1/6/22.
//

import Foundation

struct Rook: Piece {
    
    let num: Int
    
    let type = Game.PieceType.rook
    
    let side: Game.Side
    
    init(side: Game.Side, num: Int) {
        self.side = side
        self.num = num
    }
    
    
    func allPossibleMoves(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        var upRank = start.upRank()
        while upRank != nil && !board.isOccupied(upRank!, side) {
            moves.append(upRank!)
            upRank = upRank!.upRank()
        }
        var downRank = start.downRank()
        while downRank != nil && !board.isOccupied(downRank!, side) {
            moves.append(downRank!)
            downRank = downRank!.downRank()
        }
        var upFile = start.upFile()
        while upFile != nil && !board.isOccupied(upFile!, side) {
            moves.append(upFile!)
            upFile = upFile!.upFile()
        }
        var downFile = start.downFile()
        while downFile != nil && !board.isOccupied(downFile!, side) {
            moves.append(downFile!)
            downFile = downFile!.downFile()
        }
        return moves
    }
    
    func threatsCreated(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = allPossibleMoves(from: start, board)
        let upRank = start.upRank()
        if upRank != nil && board.isOccupied(upRank!, side) {
            moves.append(upRank!)
        }
        let downRank = start.downRank()
        if downRank != nil && board.isOccupied(downRank!, side) {
            moves.append(downRank!)
        }
        let upFile = start.upFile()
        if upFile != nil && board.isOccupied(upFile!, side) {
            moves.append(upFile!)
        }
        let downFile = start.downFile()
        if downFile != nil && board.isOccupied(downFile!, side) {
            moves.append(downFile!)
        }
        return moves
    }
    
    
}
