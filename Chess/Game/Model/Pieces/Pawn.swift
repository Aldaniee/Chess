//
//  Pawn.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Pawn: Piece {
    
    let id = UUID().hashValue

    var hasMoved = false
        
    let type = PieceType.pawn
    
    let side: Side
    
    init(_ side: Side) {
        self.side = side
    }
    
    func threatsCreated(from start: Coordinate, _ board: Board) -> [Coordinate] {
        return side == .white ? start.upOneDiagonals() : start.downOneDiagonals()
    }
    
    func allPossibleMoves(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        let forward = side == .white ? start.upRank() : start.downRank()
        let forwardTwo = side == .white ? forward?.upRank() : forward?.downRank()
        let attacks = threatsCreated(from: start, board)
        
        // move forward one or two swuares
        if let forward = forward {
            // Ensure the pawn only moves forward if the square ahead is empty
            if board.isEmpty(forward) {
                moves.append(forward)
                if let forwardTwo = forwardTwo {
                    if hasMoved == false && board.isEmpty(forwardTwo) {
                        moves.append(forwardTwo)
                    }
                }
            }
        }
        
        // diagonal attacks
        attacks.forEach( { end in
            if let pieceToAttack = board.getPiece(from: end) {
                let isOppositeColor = pieceToAttack.side != side
                if isOppositeColor {
                    moves.append(end)
                }
            }
        } )
        // en passant
        if start.rankNum == (side == .white ? 5 : 4) {
            var adjacent = [Coordinate]()
            if let upFile = start.upFile() {
                adjacent.append(upFile)
            }
            if let downFile = start.downFile() {
                adjacent.append(downFile)
            }
            adjacent.forEach( {
                if let pieceToAttack = board.getPiece(from: $0) {
                    let isOppositeColor = pieceToAttack.side != side
                    // TODO: Make En Passant only work when the piece just moved
                    let pieceToAttackJustMovedForwardTwo = true
                    if isOppositeColor && pieceToAttack.type == .pawn && pieceToAttackJustMovedForwardTwo {
                        if let diagonalAttack = side == .white ? $0.upRank() : $0.downRank() {
                            moves.append(diagonalAttack)
                        }
                    }
                }
            } )
        }
        return moves
    }
}