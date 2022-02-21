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
    
    private func isLegalMove(from start: Coordinate, to end: Coordinate) -> Bool {
        return legalMoves(from: start).contains(Move(game, from: start, to: end))
    }
    private func legalMoves(from start: Coordinate) -> [Move] {
        if let piece = game.getPiece(start) {
            return piece.possibleMoves(from: start, game)
        }
        return [Move]()
    }
    
    // MARK: - Intents
    func newGame() {
        game = Game()
    }
    
    func makeMoveIfLegal(from start: Coordinate, to end: Coordinate) -> Bool {
        if game.getPiece(start) != nil {
            if isLegalMove(from: start, to: end) {
                _ = game.movePiece(from: start, to: end)
                return true
            }
        }
        return false
    }
    
}
