//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

protocol Piece {
    func allPossibleMoves(_ start: Coordinate) -> [Coordinate]
    func display() -> String
    var color: Color { get }
}
