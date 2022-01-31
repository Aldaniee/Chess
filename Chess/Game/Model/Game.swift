//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

enum GameError: Error {
    case missingKing
}

typealias CastleRights = (queenSide: Bool, kingSide: Bool)
typealias Board = [Rank]
typealias Rank = [Tile]
typealias PieceCounter = (piece: Piece, count: Int)

struct Game {

    private (set) var id: UUID
    
    private (set) var board: Board
    private (set) var turn: Side
    private (set) var whiteCanCastle: CastleRights
    private (set) var blackCanCastle: CastleRights

    private (set) var enPassantTarget: Coordinate?
    private (set) var halfMoveClock: Int // used for 50 move rule
    private (set) var fullMoveNumber: Int // move counter
    
    private (set) var gameStatus: GameStatus
    
    private (set) var pgn = [FullMove]() // portable game notation
    
    private (set) var whiteCapturedPieces: [PieceCounter]
    private (set) var blackCapturedPieces: [PieceCounter]
    
    init(
        id: UUID = UUID(),
        board: Board = FEN.shared.makeBoard(from: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"),
        fenBoard: String? = nil,
        turn: Side = Side.white,
        whiteCanCastle: (queenSide: Bool, kingSide: Bool) = (true, true),
        blackCanCastle: (queenSide: Bool, kingSide: Bool) = (true, true),
        enPassantTargetSquare: Coordinate? = nil,
        halfMoveClock: Int = 0,
        fullMoveNumber: Int = 1,
        gameStatus: GameStatus = .playing,
        pgn: [FullMove] = [FullMove](),
        whiteCapturedPieces: [(piece: Piece, count: Int)] = [(Piece, Int)](),
        blackCapturedPieces: [(piece: Piece, count: Int)] = [(Piece, Int)]()
    )
    {
        self.id = id
        if let fenBoard = fenBoard {
            self.board = FEN.shared.makeBoard(from: fenBoard)
        } else {
            self.board = board
        }
        self.turn = turn
        self.whiteCanCastle = whiteCanCastle
        self.blackCanCastle = blackCanCastle
        self.enPassantTarget = enPassantTargetSquare
        self.halfMoveClock = halfMoveClock
        self.gameStatus = gameStatus
        self.pgn = pgn
        self.fullMoveNumber = fullMoveNumber
        self.whiteCapturedPieces = whiteCapturedPieces
        self.blackCapturedPieces = blackCapturedPieces
    }
    
    mutating func nextTurn() {
        turn = turn.opponent
    }
    
    mutating func setGameStatus(_ gameStatus: GameStatus) {
        self.gameStatus = gameStatus
    }
    
    mutating func changeCastlingRights(_ side: Side, queenSide: Bool? = nil, kingSide: Bool? = nil) {
        if let queenSide = queenSide {
            if side == .white {
                whiteCanCastle.queenSide = queenSide
            } else {
                blackCanCastle.queenSide = queenSide
            }
        }
        if let kingSide = kingSide {
            if side == .white {
                whiteCanCastle.kingSide = kingSide
            } else {
                blackCanCastle.kingSide = kingSide
            }
        }
    }
    // MARK: - Data Mutating Actions
    mutating func putPiece(_ piece: Piece?, _ coordinate: Coordinate) -> Piece? {
        let oldPiece = getPiece(from: coordinate)
        setPiece(piece, coordinate)
        return oldPiece
    }
    mutating func removePiece(_ coordinate: Coordinate) -> Piece? {
        putPiece(nil, coordinate)
    }
    
    mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        if let piece = getPiece(from: start) { // ensure a piece is on that tile
            _ = removePiece(start)
            return putPiece(piece, end)
        }
        return nil
    }
    
    mutating func recordCapture(piece: Piece) {
        if piece.side == .white {
            self.blackCapturedPieces = self.blackCapturedPieces.appendAndSort(piece: piece)
        } else {
            self.whiteCapturedPieces = self.whiteCapturedPieces.appendAndSort(piece: piece)
        }
    }
    mutating func recordMove(_ move: Move) {
        if turn == .white {
            pgn.append(FullMove(white: move, black: nil))
            fullMoveNumber += 1
        } else {
            let fullMove = FullMove(white: pgn.last!.white, black: move)
            pgn.removeLast()
            pgn.append(fullMove)
        }
        halfMoveClock += 1
        if move.piece.type == .pawn || move.capturedPiece != nil {
            halfMoveClock = 0
        }
    }
    mutating func moveBackwards() {
        if let lastMove = pgn.last {
            let lastHalfMove = lastMove.black ?? lastMove.white
            _ = movePiece(from: lastHalfMove.end, to: lastHalfMove.start)
            _ = putPiece(lastHalfMove.capturedPiece, lastHalfMove.end)
            nextTurn()
            removeRecordedMove()
        }
    }
    
    // MARK: - Access Functions
    func getPiece(from coordinate: Coordinate) -> Piece? {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    func getAllTilesWithPieces(of side: Side) -> [Tile] {
        var tiles = [Tile]()
        asArray().forEach { tile in
            if let piece = tile.piece {
                if piece.side == side {
                    tiles.append(tile)
                }
            }
        }
        return tiles
    }
    
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    func legalMoves(from tile: Tile) -> [Move] {
        if let piece = tile.piece {
            return piece.possibleMoves(from: tile.coordinate, self)
        }
        return [Move]()
    }
    
    func isMovingIntoCheck(from start: Coordinate, to end: Coordinate) -> Bool {
        var newState = self.copy()
        _ = newState.movePiece(from: start, to: end)
        return newState.isCheck()
    }
    /// Determines if the side whose turn it is is in check
    func isCheck() -> Bool {
        let kingSide = turn
        let attackingSide = turn.opponent
        do {
            let kingTile = try getKingTile(kingSide)
            let tilesWithAttackingPieces = getAllTilesWithPieces(of: attackingSide)
            for tile in tilesWithAttackingPieces {
                let threats = tile.piece!.threatsCreated(from: tile.coordinate, self)
                for threat in threats {
                    if threat == kingTile.coordinate {
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
    func isCheckmate() -> Bool {
        return isCheck() && hasNoMoves()
    }
    /// Determines if the game is a draw
    func isDraw() -> Bool {
        return !isCheck() && hasNoMoves()
    }
    func isOccupied(at coordinate: Coordinate, by side: Side) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == side
        }
        return false
    }
    func isEmpty(_ coordinate: Coordinate) -> Bool {
        return getPiece(from: coordinate) == nil
    }
    func asArray() -> [Tile] {
        return Array(board.joined())
    }
    func copy() -> Game {
        return Game(id: id, board: board, turn: turn, whiteCanCastle: whiteCanCastle, blackCanCastle: blackCanCastle, enPassantTargetSquare: enPassantTarget, halfMoveClock: halfMoveClock, fullMoveNumber: fullMoveNumber, gameStatus: gameStatus, pgn: pgn, whiteCapturedPieces: whiteCapturedPieces, blackCapturedPieces: blackCapturedPieces)
    }
    
    // MARK: - Private Accessors
    private func hasNoMoves() -> Bool {
        var result = true
        getAllTilesWithPieces(of: turn).forEach { tile in
            if !legalMoves(from: tile).isEmpty {
                result = false
                return
            }
        }
        return result
    }
    
    // Should never return nil as a king is always on the board
    private func getKingTile(_ side: Side) throws -> Tile {
        var king: Tile? = nil
        asArray().forEach { tile in
            if let piece = tile.piece {
                if piece.side == side && piece.type == .king {
                    king = tile
                }
            }
        }
        if let king = king {
            return king
        }
        throw GameError.missingKing
    }
    
    private func setupBoard(from fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") -> [[Tile]] {
        return FEN.shared.makeBoard(from: fen)
    }
    
    // MARK: - Private Mutators
    private mutating func setPiece(_ piece: Piece?, _ coordinate: Coordinate) {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    private mutating func removeRecordedMove() {
        if let fullMoveToRemove = pgn.last {
            pgn.removeLast()
            if turn == .black {
                let fullMove = FullMove(white: fullMoveToRemove.white, black: nil)
                pgn.append(fullMove)
            } else {
                fullMoveNumber -= 1
            }
        }
    }
    
    // MARK: - Debug
    func displayBoardInConsole() {
        for file in board {
            print()
            for tile in file {
                if let piece = tile.piece {
                    print("\(piece.type.rawValue) ", terminator: "")
                }
                else {
                    print(tile.coordinate.algebraicNotation, terminator: "")
                }
            }
        }
    }
}
