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
    
    func getPiece(_ coordinate: Coordinate) -> Piece? {
        return game.getPiece(coordinate)
    }
    func isValidMove(from start: Coordinate, to end: Coordinate) -> Bool {
        if let piece = getPiece(start) {
            return legalMoves(from: start).contains(Move(piece, from: start, to: end))
        }
        return false
    }
    
    /// Get all legal moves for a piece at the given coordinate
    func legalMoves(from coordinate: Coordinate) -> [Move] {
        if let piece = getPiece(coordinate) {
            return piece.possibleMoves(from: coordinate, game)
        }
        return [Move]()
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
