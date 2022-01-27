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
    
    let points = 100
    
    init(_ side: Side) {
        self.side = side
    }
    
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
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
    
    func allPossibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = self.getMovesFromThreats(from: start, game)

        // Add castling moves
        if !game.isCheck() {
            // king side
            if let newRookCords = start.upFile(),
               game.canShortCastle(side),
               game.isEmpty(newRookCords),
               !game.doesMoveIntoCheck(from: start, to: newRookCords),
               let newKingCords = newRookCords.upFile(),
               game.isEmpty(newKingCords),
               let rookCords = newKingCords.upFile(),
               let piece = game.getPiece(from: rookCords),
               piece.type == .rook
            {
                moves.append(Move(game, from: start, to: newKingCords))
            }
            // queen side
            if let newRookCords = start.downFile(),
               game.canLongCastle(side),
               game.isEmpty(newRookCords),
               !game.doesMoveIntoCheck(from: start, to: newRookCords),
               let newKingCords = newRookCords.downFile(),
               game.isEmpty(newKingCords),
               let empty = newKingCords.downFile(),
               game.isEmpty(empty),
               let rookCords = empty.downFile(),
               let piece = game.getPiece(from: rookCords),
               piece.type == .rook
            {
                moves.append(Move(game, from: start, to: newKingCords))
            }
        }
        return moves
    }
}
