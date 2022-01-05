//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

protocol Piece {
    func allPossibleMoves(from start: Coordinate, board: Board) -> [Coordinate]
    var type: Game.PieceType { get }
    var side: Game.Side { get }
}
extension Piece {
    var image: Image {
        let assetName = "\(side.abbreviation)_\(type.name)_shadow"
        return Image(assetName)
    }
}
