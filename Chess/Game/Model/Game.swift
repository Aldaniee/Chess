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
        self.setupBoard()
    }
    
    // MARK: - Mutators
    mutating func putPiece(_ piece: Piece?, _ coordinate: Coordinate) -> Piece? {
        let oldPiece = getPiece(from: coordinate)
        setPiece(piece, coordinate)
        return oldPiece
    }
    mutating func removePiece(_ coordinate: Coordinate) -> Piece? {
        putPiece(nil, coordinate)
    }
    
    // MARK: - Accessors
    func getPiece(from coordinate: Coordinate) -> Piece? {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    // MARK: - Private Mutators
    private mutating func setupBoard() {
        setPiece(King(.white), Coordinate(notation: "e1"))
        setPiece(King(.black), Coordinate(notation: "e8"))
    }
    private mutating func setPiece(_ piece: Piece?, _ coordinate: Coordinate) {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    
    // MARK: - Static
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
