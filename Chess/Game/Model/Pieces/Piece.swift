//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

// MARK: - Implementations: King, Knight, Pawn, RecursivePieces
protocol Piece {
    // get all legal move options this piece has
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    
    // get all coordinates this piece threatens
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    
    var type: PieceType { get }
    var side: Side { get }
    var id: Int { get }
    var points: Int { get }
}
extension Piece {
    var image: Image {
        let assetName = "\(side.rawValue)_\(type)_svg_withShadow"
        return Image(assetName)
    }
    func possibleMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for end in threatsCreated(from: start, game) {
            if !game.isOccupied(at: end, by: side) {
                moves.append(Move(game, from: start, to: end))
            }
        }
        return moves
    }
}

enum PieceType : String {
    case pawn = "P"
    case king = "K"
    case queen = "Q"
    case rook = "R"
    case knight = "N"
    case bishop = "B"
}
