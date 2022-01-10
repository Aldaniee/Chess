//
//  Knight.swift
//  Chess
//
//  Created by Aidan Lee on 1/7/22.
//

import Foundation

class Knight: Piece {
    
    var hasMoved = false
    
    var num: Int
    
    let type = Game.PieceType.knight
    
    let side: Game.Side
    
    init(side: Game.Side, num: Int) {
        self.side = side
        self.num = num
    }
    
    func threatsCreated(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        
        if let upTwo = start.upRank()?.upRank() {
            if let upTwoUpFile = upTwo.upFile() {
                moves.append(upTwoUpFile)
            }
            if let upTwoDownFile = upTwo.downFile() {
                moves.append(upTwoDownFile)
            }
        }
        if let downTwo = start.downRank()?.downRank() {
            if let downTwoUpFile = downTwo.upFile() {
                moves.append(downTwoUpFile)
            }
            if let downTwoDownFile = downTwo.downFile() {
                moves.append(downTwoDownFile)
            }
        }
        if let upTwo = start.upFile()?.upFile() {
            if let upTwoUpRank = upTwo.upRank() {
                moves.append(upTwoUpRank)
            }
            if let upTwoDownRank = upTwo.downRank() {
                moves.append(upTwoDownRank)
            }
        }
        if let downTwo = start.downFile()?.downFile() {
            if let downTwoUpRank = downTwo.upRank() {
                moves.append(downTwoUpRank)
            }
            if let downTwoDownRank = downTwo.downRank() {
                moves.append(downTwoDownRank)
            }
        }
        
        return moves
    }
    
    func allPossibleMoves(from start: Coordinate, _ board: Board) -> [Coordinate] {
        self.getMovesFromThreats(from: start, board)
    }
}
