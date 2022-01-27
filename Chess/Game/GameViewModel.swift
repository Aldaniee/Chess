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
    func getPiece(from coordinate: Coordinate) -> Piece? {
        return game.getPiece(from: coordinate)
    }
    var turn: Side {
        game.turn
    }
    func isValidMove(_ piece: Piece, from start: Coordinate, to end: Coordinate) -> Bool {
        return legalMoves(from: Tile(start, piece)).contains(end)
    }
    
    // MARK: - Intents
    func promotePawn(from start: Coordinate, to end: Coordinate, into piece: Piece) {
        let pawn = Pawn(end.rankNum == 8 ? .white : .black)
        move(pawn, from: start, to: end, promotesTo: piece)
        _ = game.putPiece(piece, end)
    }
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
    func move(_ piece: Piece, from start: Coordinate, to end: Coordinate, promotesTo promotion: Piece? = nil) {

        let moves = legalMoves(from: Tile(start, piece))
        if moves.contains(end) {
            var capturedPiece = game.putPiece(piece, end)
            _ = game.removePiece(start)
            
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
            let move = Move(
                from: start,
                to: end,
                with: piece,
                capturing: capturedPiece,
                withCheck: isCheck(game),
                withCheckmate: isCheckmate(game),
                promotesTo: promotion
            )
            changeCastlingRights(after: move)
            game.recordMove(move)
            nextTurn()
        }
    }
    
    // MARK: - Private
    private func nextTurn() {
        game.nextTurn()
        if isCheckmate(game) {
            game.setGameStatus(.checkmating)
        }
        else if isDraw(game) {
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
    
    private func hasNoMoves(_ game: Game) -> Bool {
        var result = true
        game.getAllTilesWithPieces(of: game.turn).forEach { tile in
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
            if piece.type == .king && !isCheck(game) {
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
        return isCheck(newState)
    }
    
    /// Determines if the side whose turn it is is in check
    /// - Parameters:
    ///   - state: Board state to check
    /// - Returns: if the side whose turn it is is in check
    private func isCheck(_ state: Game) -> Bool {
        // define sides
        let kingSide = game.turn
        let attackingSide = kingSide.opponent
        do {
            let kingTile = try state.getKingTile(kingSide)
            let tilesWithAttackingPieces = state.getAllTilesWithPieces(of: attackingSide)
            for tile in tilesWithAttackingPieces {
                let moves = tile.piece!.threatsCreated(from: tile.coordinate, state)
                for move in moves {
                    if move == kingTile.coordinate {
                        return true
                    }
                }
            }
        } catch {
            print("ERROR: invalid board state \(error)")
        }
        return false
    }
    /// Determines if the side whose turn it is is in checkmate
    /// - Parameters:
    ///   - state: Board state to check
    /// - Returns: if the side whose turn it is is in checkmate
    private func isCheckmate(_ state: Game) -> Bool {
        return isCheck(state) && hasNoMoves(state)
    }
    /// Determines if the game is a draw
    /// - Parameters:
    ///   - state: Board state to check
    /// - Returns: if the side whose turn it is is in checkmate
    private func isDraw(_ state: Game) -> Bool {
        return !isCheck(state) && hasNoMoves(state)
    }
}
