//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

protocol Piece {
    // get all legal move options this piece has
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    
    // get all coordinates this piece threatens
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    
    var type: PieceType { get }
    var side: Side { get }
}
extension Piece {
    var image: Image {
        return Image("\(side.rawValue)_\(type)_svg_withShadow")
    }
    
    func possibleMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for end in threatsCreated(from: start, game) {
            // TODO: if square not occupied by same color and not moving into check
            moves.append(Move(game, from: start, to: end))
        }
        return moves
    }
}

enum PieceType : String {
    case pawn, rook, knight, bishop, king, queen
}

enum Side: String {
    case white = "w"
    case black = "b"
}
