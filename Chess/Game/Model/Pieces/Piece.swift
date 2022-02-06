//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

// MARK: - Implementations: King, Knight, Pawn, RecursivePieces
protocol Piece {
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    var type: PieceType { get }
    var side: Side { get }
}
extension Piece {
    var image: Image {
        let assetName = "\(side.rawValue)_\(type.rawValue)_svg_withShadow"
        return Image(assetName)
    }
    func possibleMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for end in threatsCreated(from: start, game) {
            if !game.isOccupied(at: end, by: side) {
                let move = Move(game, from: start, to: end)
                moves.append(move)
            }
        }
        return moves
    }
}


enum PieceType: String {
    case pawn, king, queen, rook, bishop, knight
}

enum Side: String {
    case white = "w"
    case black = "b"
}
