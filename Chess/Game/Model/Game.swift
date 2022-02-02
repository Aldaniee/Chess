//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

typealias Board = [Rank]
typealias Rank = [Tile]

struct Game {

    private (set) var board: Board
    
    init() {
        self.board = Game.makeEmptyBoard()
    }
    
    // MARK: - Static
    static func makeEmptyBoard() -> Board {
        var board = Board(repeating: Rank(), count: 8)
        for rank in 0..<8 {
            for file in 0..<8 {
                board[rank].append(Tile(Coordinate(rankIndex: 7-rank, fileIndex: file)))
            }
        }
        return board
    }
}
