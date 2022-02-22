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
    
    @Published private var game: Game
    @Published var boardFlipsOnMove = false
    @Published var lastMoveWasDragged = false
    
    @Published var promotionStart: Coordinate? = nil
    @Published var promotionEnd: Coordinate? = nil
    
    // MARK: - Properties
    var boardFlipped : Bool {
        boardFlipsOnMove && turn == .black
    }
    
    var boardArray: [Tile] {
        boardFlipped
        ? Array(game.board.joined()).reversed()
        : Array(game.board.joined())
    }

    var turn: Side {
        game.turn
    }
    
    // MARK: - Accessors
    func selectedOwnPiece(_ coordinate: Coordinate) -> Bool {
        if let piece = getPiece(coordinate) {
            return piece.side == turn
        }
        return false
    }
    
    func getPiece(_ coordinate: Coordinate) -> Piece? {
        return game.getPiece(coordinate)
    }
    func isLegalMove(from start: Coordinate, to end: Coordinate, _ game: Game) -> Bool {
        return legalMoves(from: start).contains(Move(game, from: start, to: end))
    }
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    func legalMoves(from start: Coordinate) -> [Move] {
        if let piece = getPiece(start) {
            return piece.possibleMoves(from: start, game)
        }
        return [Move]()
    }
    
    // MARK: - Intents
    func newGame() {
        game = Game()
    }
    
    func toggleBoardFlipping() {
        boardFlipsOnMove = !boardFlipsOnMove
    }
    
    func makeMoveIfLegal(from start: Coordinate, to end: Coordinate) -> Bool {
        if game.getPiece(start) != nil {
            if isLegalMove(from: start, to: end, game) {
                _ = game.movePiece(from: start, to: end)
                return true
            }
        }
        return false
    }
    
}
