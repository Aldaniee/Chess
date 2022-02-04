//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    
    init(_ game: Game = Game()) {
        self.game = game
    }
    
    @Published private (set) var game: Game
    
    // MARK: - Properties
    var boardArray: [Tile] {
        Array(game.board.joined())
    }
    var turn: Side {
        game.turn
    }
    
    // MARK: - Accessors
    func selectedOwnPiece(_ coordinate: Coordinate) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == turn
        }
        return false
    }
    func getPiece(from coordinate: Coordinate) -> Piece? {
        return game.getPiece(from: coordinate)
    }
    
    func isValidMove(_ piece: Piece, from start: Coordinate, to end: Coordinate) -> Bool {
        return legalMoves(from: Tile(start, piece)).contains(Move(game, from: start, to: end))
    }
    
    // MARK: - Intents
    func newGame() {
        game = Game()
    }
    
    func move(from start: Coordinate, to end: Coordinate) {
        let move = Move(game, from: start, to: end)
        if isValidMove(move.piece, from: start, to: end) {
            _ = game.movePiece(from: start, to: end)
            game.nextTurn()
        }
    }
    
    // MARK: - Private
    
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    private func legalMoves(from tile: Tile) -> [Move] {
        if let piece = tile.piece {
            return piece.possibleMoves(from: tile.coordinate, game)
        }
        return [Move]()
    }
}

extension GameViewModel {
    // MARK: - Testing Functions
    func move(from start: String, to end: String) {
        move(from: Coordinate(notation: start), to: Coordinate(notation: end))
    }
}
