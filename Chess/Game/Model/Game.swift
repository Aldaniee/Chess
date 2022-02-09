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
        board = Game.emptyBoard
        setupPieces()
    }
    
    // MARK: - Public
    func getPiece(_ coordinate: Coordinate) -> Piece? {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    /// Moves a piece from one square to another regardless of rules
    mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        if let piece = getPiece(start) {
            removePiece(start)
            return putPiece(end, piece)
        }
        return nil
    }
    
    // MARK: - Private
    private mutating func setupPieces() {
        setPiece(Coordinate(notation: "e1"), King(.white))
        setPiece(Coordinate(notation: "e8"), King(.black))
    }
    private mutating func setPiece(_ coordinate: Coordinate, _ piece: Piece? = nil) {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    private mutating func putPiece(_ coordinate: Coordinate, _ piece: Piece? = nil) -> Piece? {
        let oldPiece = getPiece(coordinate)
        setPiece(coordinate, piece)
        return oldPiece
    }
    private mutating func removePiece(_ coordinate: Coordinate) {
        setPiece(coordinate)
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
