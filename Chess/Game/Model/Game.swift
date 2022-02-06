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
        setupBoard()
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
    
    
    /// Makes a move and applies Castling and En Passant special cases when necessary
    /// - Parameter move: A legal move from one square to another with a valid piece
    mutating func makeMove(_ move: Move) {
        let start = move.start
        let end = move.end
        _ = movePiece(from: start, to: end)
    }
    
    // MARK: - Access Functions
    func getPiece(from coordinate: Coordinate) -> Piece? {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    func legalMoves(from tile: Tile) -> [Move] {
        if let piece = tile.piece {
            return piece.possibleMoves(from: tile.coordinate, self)
        }
        return [Move]()
    }

    func isOccupied(at coordinate: Coordinate, by side: Side) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == side
        }
        return false
    }
    func isEmpty(_ coordinate: Coordinate) -> Bool {
        return getPiece(from: coordinate) == nil
    }
    
    // MARK: - Private Accessors
    
    // MARK: - Private Mutators
    private mutating func setupBoard() {
        setPiece(King(.white), Coordinate(notation: "e1"))
        setPiece(King(.black), Coordinate(notation: "e8"))
    }
    private mutating func setPiece(_ piece: Piece?, _ coordinate: Coordinate) {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    
    /// Simply moves a piece from one square to another regardless of rules
    /// - Parameters:
    ///   - start: Location of piece to move
    ///   - end: Location for piece to move to
    /// - Returns: Piece that used to be on end Tile
    private mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        let piece = removePiece(start)
        return putPiece(piece, end)
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
