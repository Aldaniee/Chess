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
    var type: PieceType { get }
    var side: Side { get }
}
extension Piece {
    var image: Image {
        return Image("\(side.rawValue)_\(type)_svg_withShadow")
    }
}

enum PieceType : String {
    case pawn, rook, knight, bishop, king, queen
}

enum Side: String {
    case white = "w"
    case black = "b"
}
