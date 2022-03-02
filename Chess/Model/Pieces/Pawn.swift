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
    
    // MARK: - Piece Protocol Functions
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        return side == .white ? start.upOneDiagonals() : start.downOneDiagonals()
    }
    
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        
        // forward one
        if let forwardOne = forward(from: start, side: side),
            game.isEmpty(forwardOne)
        {
            moves.append(Move(game, from: start, to: forwardOne))
            
            // forward two
            if isOnStartRank(from: start, side: side) {
                if let forwardTwo = forward(from: forwardOne, side: side),
                   game.isEmpty(forwardTwo)
                {
                    moves.append(Move(game, from: start, to: forwardTwo))
                }
            }
        }
        
        let attacks = threatsCreated(from: start, game)
        
        // diagonal attacks
        attacks.forEach { end in
            if let pieceToAttack = game.getPiece(end), pieceToAttack.side != side {
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
        moves.forEach { move in
            if isMovingIntoCheck(game, from: move.start, to: move.end) {
                moves.removeAll(where: { $0 == move })
            }
        }
        return moves
    }
    
    // MARK: - Private Functions
    private func forward(from start: Coordinate, side: Side) -> Coordinate? {
        return side == .white ? start.upRank() : start.downRank()
    }
    
    private func isOnStartRank(from start: Coordinate, side: Side) -> Bool{
        return side == .white ? start.rankNum == 2 : start.rankNum == 7
    }
}
