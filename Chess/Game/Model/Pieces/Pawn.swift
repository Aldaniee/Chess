//
//  Pawn.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Pawn: Piece {
    
    let id = UUID().hashValue
        
    let type = PieceType.pawn
    
    let side: Side
    
    let points = 1
    
    init(_ side: Side) {
        self.side = side
    }
    
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        return side == .white ? start.upOneDiagonals() : start.downOneDiagonals()
    }
    
    func allPossibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        // move forward one or two swuares
        if let forward = side == .white ? start.upRank() : start.downRank() {
            // Ensure the pawn only moves forward if the square ahead is empty
            if game.isEmpty(forward) {
                moves.append(Move(game, from: start, to: forward))
                if let forwardTwo = side == .white ? forward.upRank() : forward.downRank() {
                    let onStartRank = side == .white ? start.rankNum == 2 : start.rankNum == 7
                    if game.isEmpty(forwardTwo) && onStartRank {
                        moves.append(Move(game, from: start, to: forwardTwo))
                    }
                }
            }
        }
        
        let attacks = threatsCreated(from: start, game)
        // diagonal attacks
        attacks.forEach { end in
            if let pieceToAttack = game.getPiece(from: end), pieceToAttack.side != side {
                moves.append(Move(game, from: start, to: end))
            }
        }
        // en passant
        if start.rankNum == (side == .white ? 5 : 4) {
            if let upFile = start.upFile(), upFile == game.enPassantTarget {
                if let diagonalAttack = side == .white ? upFile.upRank() : upFile.downRank() {
                    moves.append(Move(game, from: start, to: diagonalAttack))
                }
            }
            if let downFile = start.downFile(), downFile == game.enPassantTarget {
                if let diagonalAttack = side == .white ? downFile.upRank() : downFile.downRank() {
                    moves.append(Move(game, from: start, to: diagonalAttack))
                }
            }
        }
        moves.removeAll { move in
            game.doesMoveIntoCheck(from: start, to: move.end)
        }
        return moves
    }
}
