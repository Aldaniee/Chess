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
        newGame(game)
    }
    
    @Published var game: Game
    
    var boardArray: Array<Tile> {
        game.asArray()
    }
    
    // MARK: - Intents
    func newGame(_ game: Game = Game()) {
        self.game = game
    }
    
    func isValidMove(_ piece: Piece, from start: Coordinate, to end: Coordinate) -> Bool {
        return legalMoves(from: Tile(start, piece)).contains(end)
    }
    
    func promotePawn(from start: Coordinate, to end: Coordinate, into piece: Piece) {
        let pawn = Pawn(end.rankNum == 8 ? .white : .black)
        move(pawn, from: start, to: end)
        _ = game.putPiece(piece, end)
    }
    
    func move(_ piece: Piece, from start: Coordinate, to end: Coordinate) {
        let moves = legalMoves(from: Tile(start, piece))
        if moves.contains(end) {
            var capturedPiece = game.putPiece(piece, end)
            _ = game.removePiece(start)
            var isReversible = true
            
            if piece.type == .king {
                // Kingside/short castle
                if start.upFile()?.upFile() == end {
                    if let rookLocation = start.upFile()?.upFile()?.upFile() {
                        _ = game.movePiece(from: rookLocation, to: start.upFile()!)
                        isReversible = false
                    }
                }
                
                // Queenside/long castle
                if start.downFile()?.downFile() == end {
                    if let rookLocation = start.downFile()?.downFile()?.downFile()?.downFile() {
                        _ = game.movePiece(from: rookLocation, to: start.downFile()!)
                        isReversible = false
                    }
                }
                
            }
            if piece.type == .pawn {
                isReversible = false
                // En Passant Special Case
                if start.isDiagonal(from: end) && capturedPiece == nil {
                    // When a pawn moves diagonally and landed on a piece it must be En Passant capturing
                    capturedPiece = game.removePiece(Coordinate(rankIndex: start.rankIndex, fileIndex: end.fileIndex))
                }
            }
            if let capturedPiece = capturedPiece {
                game.capture(piece: capturedPiece)
            }
            changeCastlingRightsAfterMove(from: start, to: end)
            let move = Move(
                from: start,
                to: end,
                with: piece,
                capturing: capturedPiece,
                withCheck: inCheck(game, game.turn.opponent),
                isReversible: isReversible
            )
            game.recordMove(move)
            nextTurn()
        }
    }
    func changeCastlingRightsAfterMove(from start: Coordinate, to end: Coordinate) {
        if let piece = getPiece(from: end) {
            let side = piece.side
            if piece.type == .king {
                if side == .white {
                    game.whiteCanCastle = (false, false)
                } else {
                    game.blackCanCastle = (false, false)
                }
            } else if piece.type == .rook {
                if side == .white {
                    if start.algebraicNotation == "A1" {
                        game.whiteCanCastle.queenSide = false
                    }
                    if start.algebraicNotation == "H1" {
                        game.whiteCanCastle.kingSide = false
                    }
                } else {
                    if start.algebraicNotation == "A8" {
                        game.blackCanCastle.queenSide = false
                    }
                    if start.algebraicNotation == "H8" {
                        game.blackCanCastle.kingSide = false
                    }
                }
            }
        }
    }
    
    func getPiece(from coordinate: Coordinate) -> Piece? {
        return game.getPiece(from: coordinate)
    }
    func getTurn() -> Side {
        return game.turn
    }
    
    // MARK: - Private
    
    private func nextTurn() {
        game.turn = game.turn == .white ? .black : .white
        if hasNoMoves(game.turn) {
            if inCheck(game, game.turn) {
                game.winner = game.turn.opponent.name
            }
            else {
                game.winner = "draw"
            }
        }
        if isThreefoldRepetition() {
            game.winner = "draw"
        }
    }
    
    private func moveBackwards(game: Game) -> Game {
        var pastGame = game.copy()
        if let lastMove = pastGame.pgn.last {
            let lastHalfMove = lastMove.black ?? lastMove.white
            _ = pastGame.movePiece(from: lastHalfMove.end, to: lastHalfMove.start)
            _ = pastGame.putPiece(lastHalfMove.capturedPiece, lastHalfMove.end)
            pastGame.removeRecordedMove()
        }
        return pastGame
    }
    
    private func isThreefoldRepetition() -> Bool {
        var tempGame = game.copy()
        var pastStates = [(state: FEN.shared.makeString(from: tempGame, withoutClocks: true), appearances: 1)]
        while tempGame.pgn.count != 0 {
            if let lastFull = tempGame.pgn.last {
                let last = lastFull.black ?? lastFull.white
                if last.isReversible != false {
                    tempGame = moveBackwards(game: tempGame)
                    if let index = pastStates.firstIndex(where: { $0.state == FEN.shared.makeString(from: tempGame, withoutClocks: true) }) {
                        pastStates[index].appearances += 1
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
    
    private func hasNoMoves(_ side: Side) -> Bool {
        var result = true
        game.getAllTilesWithPieces(of: side).forEach { tile in
            if !legalMoves(from: tile).isEmpty {
                result = false
                return
            }
        }
        return result
    }
    
    
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    private func legalMoves(from tile: Tile) -> [Coordinate] {
        if let piece = tile.piece {
            let side = piece.side
            var moves = tile.piece!.allPossibleMoves(from: tile.coordinate, game)
            
            // Add castling moves
            if piece.type == .king && !inCheck(game, game.turn) {
                // king side
                if let newRookCords = tile.coordinate.upFile(),
                   game.canShortCastle(side),
                   game.isEmpty(newRookCords),
                   !doesMoveIntoCheck(from: tile.coordinate, to: newRookCords),
                   let newKingCords = newRookCords.upFile(),
                   game.isEmpty(newKingCords),
                   let rookCords = newKingCords.upFile(),
                   let piece = game.getPiece(from: rookCords),
                   piece.type == .rook
                {
                    moves.append(newKingCords)
                }
                // queen side
                if let newRookCords = tile.coordinate.downFile(),
                   game.canLongCastle(side),
                   game.isEmpty(newRookCords),
                   !doesMoveIntoCheck(from: tile.coordinate, to: newRookCords),
                   let newKingCords = newRookCords.downFile(),
                   game.isEmpty(newKingCords),
                   let empty = newKingCords.downFile(),
                   game.isEmpty(empty),
                   let rookCords = empty.downFile(),
                   let piece = game.getPiece(from: rookCords),
                   piece.type == .rook
                {
                    moves.append(newKingCords)
                }
            }
            
            
            // Remove any moves that move into check
            for move in moves {
                if doesMoveIntoCheck(from: tile.coordinate, to: move) {
                    moves.removeAll(where: { $0 == move })
                }
            }
            return moves
        }
        return [Coordinate]()
    }
    
    private func doesMoveIntoCheck(from start: Coordinate, to end: Coordinate) -> Bool {
        var newState = game.copy()
        _ = newState.movePiece(from: start, to: end)
        return inCheck(newState, game.turn)
    }
    
    
    
    /// Checks if the side whose turn it is is in check
    /// - Parameters:
    ///   - state: Board state to check
    ///   - turn: Side whose turn it is
    /// - Returns: if the side whose turn it is is in check
    private func inCheck(_ state: Game, _ turn: Side) -> Bool {
        // define sides
        let kingSide = turn
        let attackingSide = kingSide.opponent
        
        guard let kingTile = state.getKingTile(kingSide) else { print("ERROR: No king on board"); return false }

        let attackingTiles = state.getAllTilesWithPieces(of: attackingSide)
        for tile in attackingTiles {
            guard let piece = tile.piece else { print("ERROR: Tile needs piece"); return false}
            let moves = piece.threatsCreated(from: tile.coordinate, state)
            for move in moves {
                if move == kingTile.coordinate {
                    return true
                }
            }
        }
        return false
    }
}
