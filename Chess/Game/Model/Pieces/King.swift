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
    
    let points = 4
    
    init(_ side: Side) {
        self.side = side
    }
    
    // MARK: - Piece Protocol Functions
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        return start.oneCoordinate(inEach: Coordinate.Direction.all)
    }
    
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = self.possibleMovesFromThreats(from: start, game)

        // Add castling moves
        if !game.isCheck() {
            // king side
            if let newRookCords = start.upFile(),
               canShortCastle(game, side),
               game.isEmpty(newRookCords),
               !isMovingIntoCheck(game, from: start, to: newRookCords),
               let newKingCords = newRookCords.upFile(),
               game.isEmpty(newKingCords),
               !isMovingIntoCheck(game, from: start, to: newRookCords),
               let rookCords = newKingCords.upFile(),
               let piece = game.getPiece(rookCords),
               piece.type == .rook
            {
                moves.append(Move(game, from: start, to: newKingCords))
            }
            // queen side
            if let newRookCords = start.downFile(),
               canLongCastle(game, side),
               game.isEmpty(newRookCords),
               !isMovingIntoCheck(game, from: start, to: newRookCords),
               let newKingCords = newRookCords.downFile(),
               game.isEmpty(newKingCords),
               !isMovingIntoCheck(game, from: start, to: newRookCords),
               let empty = newKingCords.downFile(),
               game.isEmpty(empty),
               let rookCords = empty.downFile(),
               let piece = game.getPiece(rookCords),
               piece.type == .rook
            {
                moves.append(Move(game, from: start, to: newKingCords))
            }
        }
        return moves
    }
    
    // MARK: - Private Functions
    func canLongCastle(_ game: Game, _ side: Side) -> Bool {
        return side == .white ? game.whiteCanCastle.queenSide : game.blackCanCastle.queenSide
    }
    
    func canShortCastle(_ game: Game, _ side: Side) -> Bool {
        return side == .white ? game.whiteCanCastle.kingSide : game.blackCanCastle.kingSide
    }
}
