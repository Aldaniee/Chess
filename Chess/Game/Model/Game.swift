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
    
    // MARK: - Data Mutating Actions
    mutating func putPiece(_ piece: Piece?, _ coordinate: Coordinate) -> Piece? {
        let oldPiece = getPiece(from: coordinate)
        setPiece(piece, coordinate)
        return oldPiece
    }
    mutating func removePiece(_ coordinate: Coordinate) -> Piece? {
        putPiece(nil, coordinate)
    }
    
    
    /// Simply moves a piece from one square to another regardless of rules
    /// - Parameters:
    ///   - start: Location of piece to move
    ///   - end: Location for piece to move to
    /// - Returns: Piece that used to be on end Tile
    private mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        let piece = removePiece(start)
        return putPiece(piece, end)
    }
    
    
    /// Makes a move and applies Castling and En Passant special cases when necessary
    /// - Parameter move: A legal move from one square to another with a valid piece
    mutating func makeMove(_ move: Move) {
        let start = move.start
        let end = move.end
        let piece = move.piece
        
        var capturedPiece = movePiece(from: start, to: end)
        if piece.type == .king {
            // Kingside/short castle
            if start.upFile()?.upFile() == end {
                if let rookLocation = start.upFile()?.upFile()?.upFile() {
                    _ = movePiece(from: rookLocation, to: start.upFile()!)
                }
            }
            
            // Queenside/long castle
            if start.downFile()?.downFile() == end {
                if let rookLocation = start.downFile()?.downFile()?.downFile()?.downFile() {
                    _ = movePiece(from: rookLocation, to: start.downFile()!)
                }
            }
            
        }
        // En Passant Special Case
        if piece.type == .pawn && start.isDiagonal(from: end) && capturedPiece == nil {
            // When a pawn moves diagonally and landed on a piece it must be En Passant capturing
            capturedPiece = removePiece(Coordinate(rankIndex: start.rankIndex, fileIndex: end.fileIndex))
        }
        if let capturedPiece = capturedPiece {
            recordCapture(piece: capturedPiece)
        }
        changeCastlingRights(after: move)
        recordMove(move)
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
    mutating func undoLastMove() {
        if let lastMove = pgn.last {
            let lastHalfMove = lastMove.black ?? lastMove.white
            let start = lastHalfMove.start
            let end = lastHalfMove.end
            let piece = lastHalfMove.piece
            
            _ = movePiece(from: end, to: start)

            // promotion
            if lastHalfMove.promotesTo != nil {
                _ = putPiece(Pawn(piece.side), start)
            }
            // capture
            if let capturedPiece = lastHalfMove.capturedPiece {
                _ = putPiece(capturedPiece, end)
            }
            // en passant
            if piece.type == .pawn
                && start.isDiagonal(from: end)
                && lastHalfMove.capturedPiece == nil
            {
                let opponenetCoordinate = Coordinate(rankIndex: start.rankIndex, fileIndex: end.fileIndex)
                _ = putPiece(Pawn(piece.side.opponent), opponenetCoordinate)
                enPassantTarget = opponenetCoordinate
            }
            // castle
            if lastHalfMove.isCastling {
                // Long Castle
                if lastHalfMove.start.fileLetter == "C" {
                    let rook = removePiece(lastHalfMove.end.upFile()!)
                    let rookCoordinates = Coordinate(fileLetter: "A", rankNum: start.rankNum)
                    _ = putPiece(rook, rookCoordinates)
                }
                // Short castle
                else {
                    let rook = removePiece(lastHalfMove.end.downFile()!)
                    let rookCoordinates = Coordinate(fileLetter: "H", rankNum: start.rankNum)
                    _ = putPiece(rook, rookCoordinates)
                }
            }
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
        newState.makeMove(Move(self, from: start, to: end))
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
    
    func isThreefoldRepetition() -> Bool {
        var tempGame = copy()
        var pastStates = [(state: FEN.shared.makeString(from: tempGame, withoutClocks: true), appearances: 1)]
        while tempGame.pgn.count != 0 {
            if let lastFull = tempGame.pgn.last {
                let last = lastFull.black ?? lastFull.white
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
    private mutating func changeCastlingRights(after move: Move) {
        let piece = move.piece
        let start = move.start
        let side = piece.side
        if piece.type == .king {
            changeCastlingRights(side, queenSide: false, kingSide: false)
        } else if piece.type == .rook {
            if (side == .white && start.algebraicNotation[1] == "1")
            || (side == .black && start.algebraicNotation[1] == "8") {
                if start.algebraicNotation == "A" {
                    changeCastlingRights(side, queenSide: false)
                }
                if start.algebraicNotation == "H" {
                    changeCastlingRights(side, kingSide: false)
                }
            }
        }
    }
    private mutating func changeCastlingRights(_ side: Side, queenSide: Bool? = nil, kingSide: Bool? = nil) {
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
