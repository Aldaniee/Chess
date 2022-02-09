//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    
    @Published private (set) var game = Game()
    
    // MARK: - Properties
    var boardArray: [Tile] {
        Array(game.board.joined())
    }
    
    // MARK: - Accessors
    
    func getPiece(from coordinate: Coordinate) -> Piece? {
        return game.getPiece(from: coordinate)
    }
    func isValidMove(from start: Coordinate, to end: Coordinate) -> Bool {
        if getPiece(from: start) != nil {
            return game.legalMoves(from: Tile(start, game.getPiece(from: start))).contains(Move(game, from: start, to: end))
        }
        return false
    }
    
    // MARK: - Intents
    func newGame() {
        game = Game()
    }
    
    func makeMoveIfValid(from start: Coordinate, to end: Coordinate) -> Bool {
        if isValidMove(from: start, to: end) {
            _ = game.movePiece(from: start, to: end)
            return true
        }
        return false
    }
    
}
