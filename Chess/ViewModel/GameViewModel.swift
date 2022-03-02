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
    
    var enPassantTarget: Coordinate? {
        game.enPassantTarget
    }
    
    var lastMove: Move? {
        game.pgn.last
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
    var gameStatus: GameStatus {
        game.gameStatus
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
    func isLegalMove(from start: Coordinate, to end: Coordinate) -> Bool {
        return legalMoves(from: start).contains(Move(game, from: start, to: end))
    }
    func isCheck() -> Bool {
        return game.isCheck()
    }
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    func legalMoves(from start: Coordinate) -> [Move] {
        if let piece = getPiece(start) {
            return piece.possibleMoves(game)
        }
        return [Move]()
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
    
    func makeMoveIfLegal(from start: Coordinate, to end: Coordinate, promotesTo promotion: Piece? = nil) -> Bool {
        if let movingPiece = getPiece(start), movingPiece.side == turn, !selectedOwnPiece(end) {
            if movingPiece.type == .pawn && (end.rankNum == 1 || end.rankNum == 8) && isLegalMove(from: start, to: end) {
                promotionStart = start
                promotionEnd = end
                return true
            }
            if isLegalMove(from: start, to: end) {
                game.makeMove(Move(game, from: start, to: end, promotesTo: promotion))
                nextTurn()
                return true
            }
        }
        return false
    }
    
    /// Determines if the side whose turn it is is in checkmate
    func isCheckmate() -> Bool {
        return game.isCheck() && hasNoMoves(game)
    }
    /// Determines if the game is a draw
    func isDraw() -> Bool {
        return !game.isCheck() && hasNoMoves(game)
    }
    // MARK: - Private
    private func hasNoMoves(_ game: Game) -> Bool {
        var result = true
        game.getAllTilesWithPieces(turn).forEach { tile in
            if !legalMoves(from: tile.coordinate).isEmpty {
                result = false
                return
            }
        }
        return result
    }
    func isThreefoldRepetition() -> Bool {
        var tempGame = game.copy()
        var pastStates = [(state: FEN.shared.makeString(from: tempGame, withoutClocks: true), appearances: 1)]
        while tempGame.pgn.count != 0 {
            if let last = tempGame.pgn.last {
                if last.isReversible {
                    tempGame.undoLastMove()
                    if let index = pastStates.firstIndex(where: { $0.state == FEN.shared.makeString(from: tempGame, withoutClocks: true) }) {
                        pastStates[index].appearances += 1
                        print("\(pastStates[index].state) \(pastStates[index].appearances)")
                        if pastStates[index].appearances == 3 {
                            return true
                        }
                    } else {
                        pastStates.append((state: FEN.shared.makeString(from: tempGame, withoutClocks: true), appearances: 1))
                    }
                }
                else {
                    return false
                }
            }
        }
        return false
    }
    private func nextTurn() {
        game.nextTurn()
        if isCheckmate() {
            game.setGameStatus(.checkmating)
        }
        else if isDraw() {
            game.setGameStatus(.drawingByPosition)
        }
        else if isThreefoldRepetition() {
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
    
    // MARK: - Testing Clarity Functions
    func makeMultipleMovesIfValid(_ pgnMoveNotation: String) -> Bool {
        let moveStrings = pgnMoveNotation.split(separator: " ")
        for moveString in moveStrings {
            if !moveString[0].isNumber {
                if !makeMoveIfLegal(moveString.description) {
                    return false
                }
            }
        }
        return true
    }
    
    func makeMoveIfLegal(_ moveNotation: String) -> Bool {
        do {
            let move = try Move(game, moveNotation: moveNotation)
            return makeMoveIfLegal(from: move.start, to: move.end, promotesTo: move.promotesTo)
        } catch {
            print("ERROR: Move error: \(error)")
        }
        return false
    }
    
}
