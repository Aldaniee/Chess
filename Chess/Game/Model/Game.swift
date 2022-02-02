//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

typealias Board = [[Tile]]

struct Game {
    
    private (set) var board: Board
    
    init() {
        self.board = Game.emptyBoard
    }
    
    // MARK: Static
    static var emptyBoard: Board {
        var board = Board(repeating: [Tile](), count: 8)
        for rank in 0...7 {
            for file in 0...7 {
                board[rank].append(Tile(Coordinate(7-rank, file)))
            }
        }
        return board
    }
}
