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
            var capturedPiece = game.movePiece(from: start, to: end)
            // Determine if the king is castling inorder to move the rook
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
            
            if piece.type == .pawn && capturedPiece == nil {
                // En Passant Special Case
                // if a pawn moves diagonal and does not land on a pawn it must be capturing a pawn via en passant
                if start.isDiagonal(from: end) {
                    capturedPiece = game.removePiece(Coordinate(rankIndex: start.rankIndex, fileIndex: end.fileIndex))
                }
            }
            if let capturedPiece = capturedPiece {
                game.capture(piece: capturedPiece)
            }
            game.recordMove(Move(from: start, to: end, with: piece.type, capturing: capturedPiece?.type, withCheck: inCheck(game, game.turn.opponent)))
            nextTurn()
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
