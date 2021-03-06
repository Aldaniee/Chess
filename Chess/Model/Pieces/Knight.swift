//
//  Knight.swift
//  Chess
//
//  Created by Aidan Lee on 1/7/22.
//

import Foundation

class Knight: Piece {
    
    let id = UUID().hashValue
            
    let type = PieceType.knight
    
    let side: Side
    
    let points = 3

    init(_ side: Side) {
        self.side = side
    }
    
    // MARK: - Piece Protocol Functions
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
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
    
    func possibleMoves(from start: Coordinate, _ board: Game) -> [Move] {
        self.possibleMovesFromThreats(from: start, board)
    }
}
