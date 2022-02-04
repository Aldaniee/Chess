//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

protocol Piece {
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    var type: PieceType { get }
    var side: Side { get }
}
extension Piece {
    var image: Image {
        Image("\(side.rawValue)_\(type.rawValue)_shadow")
    }
    func possibleMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for end in threatsCreated(from: start, game) {
            if !game.isOccupied(by: side, at: end) {
                moves.append(Move(game, from: start, to: end))
            }
        }
        return moves
    }
}

enum PieceType : String {
    case pawn, king, queen, rook, bishop, knight
}
