//
//  Pawn.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Pawn: Piece {
    
    let type = Game.PieceType.pawn
    
    let side: Game.Side
    
    init(side: Game.Side) {
        self.side = side
    }
    
    func allPossibleMoves(from start: Coordinate, board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        var forward: Coordinate?
        var forwardTwo: Coordinate?
        var attacks = [Coordinate]()
        
        if side == .white {
            forward = start.upRank()
            forwardTwo = start.upRank()?.upRank()
            attacks = start.upOneDiagonals()
        }
        else {
            forward = start.downRank()
            forwardTwo = start.downRank()?.downRank()
            attacks = start.downOneDiagonals()
        }
        if let forward = forward {
            // Ensure the pawn only moves forward if the square ahead is empty
            if board.emptySquare(forward) {
                moves.append(forward)
                if let forwardTwo = forwardTwo {
                    if start.rankNum == (side == .white ? 2 : 7) && board.emptySquare(forwardTwo) {
                        moves.append(forwardTwo)
                    }
                }
            }
        }
        
        // diagonal attacking
        
        attacks.forEach( {
            if let pieceToAttack = board.getPieceFromCoords($0) {
                let isOppositeColor = pieceToAttack.side != side
                if isOppositeColor {
                    moves.append($0)
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
                if let pieceToAttack = board.getPieceFromCoords($0) {
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
