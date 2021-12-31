//
//  Pawn.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Pawn: Piece {
    
    let isWhite: Bool
    
    func allPossibleMoves(_ start: Coordinate) -> [Coordinate] {
        var moves = [Coordinate]()
        if isWhite {
            moves.append(start.upRank())
            start.upOneDiagonals().forEach( { moves.append($0) } )
        } else {
            moves.append(start.downRank())
            start.downOneDiagonals().forEach( { moves.append($0) } )
        }
        return moves
    }
    
    init(isWhite: Bool) {
        self.isWhite = isWhite
    }
    var color: Color {
        isWhite ? Color.white : Color.black
    }
    
    func display() -> String {
        return "P"
    }
}
