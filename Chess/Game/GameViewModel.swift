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
    
    // MARK: - Accessors
    
    var pgnString: String {
        var pgnString = ""
        for index in 0..<game.pgn.count {
            pgnString.append("\(index+1). ")
            pgnString.append(game.pgn[index].display)
        }
        return pgnString
    }
    var boardArray: [Tile] {
        game.asArray()
    }
    
    func selectedOwnPiece(_ coordinate: Coordinate) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == turn
        }
        return false
    }
    
    func getPiece(from coordinate: Coordinate) -> Piece? {
        return game.getPiece(from: coordinate)
    }
    var turn: Side {
        game.turn
    }
    func isValidMove(_ piece: Piece, from start: Coordinate, to end: Coordinate) -> Bool {
        return game.legalMoves(from: Tile(start, piece)).contains(Move(game, from: start, to: end))
    }
    
    // MARK: - Intents
    func changeCastlingRights(after move: Move) {
        let piece = move.piece
        let start = move.start
        let side = piece.side
        if piece.type == .king {
            game.changeCastlingRights(side, queenSide: false, kingSide: false)
        } else if piece.type == .rook {
            if (side == .white && start.algebraicNotation[1] == "1")
            || (side == .black && start.algebraicNotation[1] == "8") {
                if start.algebraicNotation == "A" {
                    game.changeCastlingRights(side, queenSide: false)
                }
                if start.algebraicNotation == "H" {
                    game.changeCastlingRights(side, kingSide: false)
                }
            }
        }
    }
    
    // For ease of testing
    func move(from start: String, to end: String) {
        move(from: Coordinate(algebraicNotation: start), to: Coordinate(algebraicNotation: end))
    }
    
    func move(from start: Coordinate, to end: Coordinate, promotesTo promotion: Piece? = nil) {
        if let piece = getPiece(from: start) {
            let move = Move(game, from: start, to: end, promotesTo: promotion)
            let moves = game.legalMoves(from: Tile(start, piece))
            if moves.contains(move) {
                var capturedPiece = game.movePiece(from: start, to: end)
                
                if piece.type == .king {
                    // Kingside/short castle
                    if start.upFile()?.upFile() == end {
                        if let rookLocation = start.upFile()?.upFile()?.upFile() {
                            _ = game.movePiece(from: rookLocation, to: start.upFile()!)
                        }
                    }
                    
                    // Queenside/long castle
                    if start.downFile()?.downFile() == end {
                        if let rookLocation = start.downFile()?.downFile()?.downFile()?.downFile() {
                            _ = game.movePiece(from: rookLocation, to: start.downFile()!)
                        }
                    }
                    
                }
                if piece.type == .pawn {
                    // En Passant Special Case
                    if start.isDiagonal(from: end) && capturedPiece == nil {
                        // When a pawn moves diagonally and landed on a piece it must be En Passant capturing
                        capturedPiece = game.removePiece(Coordinate(rankIndex: start.rankIndex, fileIndex: end.fileIndex))
                    }
                }
                if let capturedPiece = capturedPiece {
                    game.recordCapture(piece: capturedPiece)
                }
                _ = game.putPiece(piece, end)
                changeCastlingRights(after: move)
                game.recordMove(move)
                nextTurn()
                print(FEN.shared.makeString(from: game))
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
        else if isThreefoldRepetition() {
            game.setGameStatus(.drawingByRepetition)
        }
    }

    
    private func isThreefoldRepetition() -> Bool {
        var tempGame = game.copy()
        var pastStates = [(state: FEN.shared.makeString(from: tempGame, withoutClocks: true), appearances: 1)]
        while tempGame.pgn.count != 0 {
            if let lastFull = tempGame.pgn.last {
                let last = lastFull.black ?? lastFull.white
                if last.isReversible {
                    tempGame.moveBackwards()
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
    
}
