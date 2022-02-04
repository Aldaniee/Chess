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
        return game.legalMoves(from: Tile(start, piece)).contains(Move(game, from: start, to: end))
    }
    
    // MARK: - Intents
    func newGame() {
        game = Game()
    }
    
    // For ease of testing
    func move(from start: String, to end: String) {
        move(from: Coordinate(notation: start), to: Coordinate(notation: end))
    }
    
    func move(from start: Coordinate, to end: Coordinate, promotesTo promotion: Piece? = nil) {
        if let piece = getPiece(from: start) {
            let move = Move(game, from: start, to: end, promotesTo: promotion)
            let moves = game.legalMoves(from: Tile(start, piece))
            if moves.contains(move) {
                game.makeMove(move)
                nextTurn()
            }
        }
    }
    
    // MARK: - Private
    private func nextTurn() {
        game.nextTurn()
        if game.isCheckmate() {
            game.setGameStatus(.checkmating)
        }
        else if game.isDraw() {
            game.setGameStatus(.drawingByPosition)
        }
        else if game.isThreefoldRepetition() {
            game.setGameStatus(.drawingByRepetition)
        }
    }
    
}
