//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

enum GameError: Error {
    case missingKing
}

typealias Board = [[Tile]]

struct Game {

    private (set) var board: Board
    private (set) var turn: Side
    
    init() {
        self.board = Game.emptyBoard
        self.turn = .white
        self.setupBoard()
    }
    
    // MARK: - Data Mutating Actions
    mutating func setupBoard() {
        setPiece(King(.white), Coordinate(notation: "e1"))
        setPiece(King(.black), Coordinate(notation: "e8"))
    }
    
    
    mutating func nextTurn() {
        turn = turn.opponent
    }
    
    mutating func putPiece(_ piece: Piece?, _ coordinate: Coordinate) -> Piece? {
        let oldPiece = getPiece(from: coordinate)
        setPiece(piece, coordinate)
        return oldPiece
    }
    mutating func removePiece(_ coordinate: Coordinate) -> Piece? {
        putPiece(nil, coordinate)
    }
    
    mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        if let piece = getPiece(from: start) { // ensure a piece is on that tile
            _ = removePiece(start)
            return putPiece(piece, end)
        }
        return nil
    }
    
    // MARK: - Access Functions
    func getPiece(from coordinate: Coordinate) -> Piece? {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    func isOccupied(by side: Side, at coordinate: Coordinate) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == side
        }
        return false
    }
    func isEmpty(_ coordinate: Coordinate) -> Bool {
        return getPiece(from: coordinate) == nil
    }
    // MARK: - Private Mutators
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
