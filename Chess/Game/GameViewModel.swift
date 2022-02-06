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
    @Published var boardFlipsOnMove = false

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
    var whiteCapturedPieces: [PieceCounter] {
        game.whiteCapturedPieces
    }
    var blackCapturedPieces: [PieceCounter] {
        game.blackCapturedPieces
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
    func isValidMove(from start: Coordinate, to end: Coordinate) -> Bool {
        return game.legalMoves(from: Tile(start, game.getPiece(from: start))).contains(Move(game, from: start, to: end))
    }
    
    func getMaterialBalance(_ side: Side) -> Int {
        let whiteCapturedPoints = capturedPoints(.white)
        let blackCapturedPoints = capturedPoints(.black)
        let balance = whiteCapturedPoints - blackCapturedPoints
        if side == .white {
            return balance > 0 ? balance : 0
        } else {
            return balance < 0 ? balance * -1 : 0
        }
    }
    
    // MARK: - Intents
    func newGame() {
        game = Game()
    }
    
    func toggleBoardFlipping() {
        boardFlipsOnMove = !boardFlipsOnMove
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
    
    private func capturedPoints(_ side: Side) -> Int {
        let capturedPieces = side == .white ? game.whiteCapturedPieces : game.blackCapturedPieces
        var sum = 0
        for pieceCounter in capturedPieces {
            sum += pieceCounter.count * pieceCounter.piece.points
        }
        return sum
    }
    
}
