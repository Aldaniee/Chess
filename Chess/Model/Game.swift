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
typealias Board = [[Tile]]
typealias PieceCounter = (piece: Piece, count: Int)

struct Game {
    
    private (set) var board: Board
    private (set) var turn: Side
    private (set) var whiteCanCastle: CastleRights
    private (set) var blackCanCastle: CastleRights

    private (set) var enPassantTarget: Coordinate?
    private (set) var halfMoveClock: Int // used for 50 move rule
    private (set) var fullMoveNumber: Int // move counter
    
    private (set) var gameStatus: GameStatus
    
    private (set) var pgn = [Move]() // portable game notation
    
    private (set) var whiteCapturedPieces: [PieceCounter]
    private (set) var blackCapturedPieces: [PieceCounter]
    
    private var consoleDebug = false
    
    init(
        board: Board = FEN.shared.makeBoard(from: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"),
        fenBoard: String? = nil,
        turn: Side = Side.white,
        whiteCanCastle: (queenSide: Bool, kingSide: Bool) = (true, true),
        blackCanCastle: (queenSide: Bool, kingSide: Bool) = (true, true),
        enPassantTargetSquare: Coordinate? = nil,
        halfMoveClock: Int = 0,
        fullMoveNumber: Int = 1,
        gameStatus: GameStatus = .playing,
        pgn: [Move] = [Move](),
        whiteCapturedPieces: [PieceCounter] = [PieceCounter](),
        blackCapturedPieces: [PieceCounter] = [PieceCounter]()
    )
    {
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
    
    // MARK: - Public
    mutating func nextTurn() {
        turn = turn.opponent
        if consoleDebug {
            print(FEN.shared.makeString(from: self))
            print(pgnString())
        }
    }
    
    mutating func setGameStatus(_ gameStatus: GameStatus) {
        self.gameStatus = gameStatus
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
        if piece.type == .pawn {
            // Promotion Special Case
            if let promotion = move.promotesTo {
                setPiece(end, promotion)
            }
            
            // En Passant Special Case
            if start.isDiagonal(from: end) && capturedPiece == nil {
            // When a pawn moves diagonally and landed on a piece it must be En Passant capturing
                let captureCoordinate = Coordinate(start.rankIndex, end.fileIndex)
                capturedPiece = getPiece(captureCoordinate)
                removePiece(captureCoordinate)
            }
            
            if start.distance(to: end) == 2 {
                enPassantTarget = end
            } else {
                enPassantTarget = nil
            }
        } else {
            enPassantTarget = nil
        }
        if let capturedPiece = capturedPiece {
            recordCapture(capturedPiece)
        }
        changeCastlingRights(after: move)
        recordMove(move)
    }
    mutating func undoLastMove() {
        if let lastMove = pgn.last {
            let start = lastMove.start
            let end = lastMove.end
            let piece = lastMove.piece
            
            _ = movePiece(from: end, to: start)

            // promotion
            if lastMove.promotesTo != nil {
                _   = putPiece(start, Pawn(piece.side))
            }
            // capture
            if let capturedPiece = lastMove.capturedPiece {
                _ = putPiece(end, capturedPiece)
            }
            // en passant
            if piece.type == .pawn
                && start.isDiagonal(from: end)
                && lastMove.capturedPiece == nil
            {
                let opponenetCoordinate = Coordinate(start.rankIndex, end.fileIndex)
                _ = putPiece(opponenetCoordinate, Pawn(piece.side.opponent))
                enPassantTarget = opponenetCoordinate
            }
            // castle
            if lastMove.isCastling {
                // Long Castle
                if lastMove.start.fileLetter == "C" {
                    let oldRookCoordinates = lastMove.end.upFile()!
                    setPiece(Coordinate(fileLetter: "A", rankNum: start.rankNum),  getPiece(oldRookCoordinates))
                    removePiece(oldRookCoordinates)
                }
                // Short castle
                else {
                    let oldRookCoordinates = lastMove.end.downFile()!
                    setPiece(Coordinate(fileLetter: "H", rankNum: start.rankNum),  getPiece(oldRookCoordinates))
                    removePiece(oldRookCoordinates)
                }
            }
            nextTurn()
            removeRecordedMove()
        }
    }
    func getPiece(_ coordinate: Coordinate) -> Piece? {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    func pgnString() -> String {
        var pgnString = ""
        for index in 0..<pgn.count {
            if index.isMultiple(of: 2) {
                pgnString.append("\(index/2 + 1). ")
            }
            pgnString.append(pgn[index].asShortNotation(self))
            pgnString.append(" ")
        }
        return pgnString
    }
    
    func getAllTilesWithPieces(_ side: Side) -> [Tile] {
        var tiles = [Tile]()
        Array(board.joined()).forEach { tile in
            if let piece = tile.piece {
                if piece.side == side {
                    tiles.append(tile)
                }
            }
        }
        return tiles
    }
    /// Determines if the side whose turn it is is in check
    func isCheck() -> Bool {
        let kingSide = turn
        let attackingSide = turn.opponent
        do {
            let kingTile = try getKingTile(kingSide)
            let tilesWithAttackingPieces = getAllTilesWithPieces(attackingSide)
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

    func isOccupied(at coordinate: Coordinate, by side: Side) -> Bool {
        if let piece = getPiece(coordinate) {
            return piece.side == side
        }
        return false
    }
    func isEmpty(_ coordinate: Coordinate) -> Bool {
        return getPiece(coordinate) == nil
    }
    func copy() -> Game {
        return Game(board: board, turn: turn, whiteCanCastle: whiteCanCastle, blackCanCastle: blackCanCastle, enPassantTargetSquare: enPassantTarget, halfMoveClock: halfMoveClock, fullMoveNumber: fullMoveNumber, gameStatus: gameStatus, pgn: pgn, whiteCapturedPieces: whiteCapturedPieces, blackCapturedPieces: blackCapturedPieces)
    }
    // Should never return nil as a king is always on the board
    func getKingTile(_ side: Side) throws -> Tile {
        var king: Tile? = nil
        Array(board.joined()).forEach { tile in
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
    // MARK: - Private
    private mutating func putPiece(_ coordinate: Coordinate, _ piece: Piece? = nil) -> Piece? {
        let oldPiece = getPiece(coordinate)
        setPiece(coordinate, piece)
        return oldPiece
    }
    private mutating func setPiece(_ coordinate: Coordinate, _ piece: Piece? = nil) {
        board[7-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    private mutating func removePiece(_ coordinate: Coordinate) {
        setPiece(coordinate)
    }
    /// Simply moves a piece from one square to another regardless of rules
    /// - Parameters:
    ///   - start: Location of piece to move
    ///   - end: Location for piece to move to
    /// - Returns: Piece that used to be on end Tile
    private mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        if let piece = getPiece(start) {
            removePiece(start)
            return putPiece(end, piece)
        }
        return nil
    }
    private func setupBoard(from fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") -> [[Tile]] {
        return FEN.shared.makeBoard(from: fen)
    }
    private mutating func recordMove(_ move: Move) {
        pgn.append(move)
        halfMoveClock += 1
        if move.piece.type == .pawn || move.capturedPiece != nil {
            halfMoveClock = 0
        }
        if move.piece.side == .white {
            fullMoveNumber += 1
        }
    }
    private mutating func recordCapture(_ piece: Piece) {
        if piece.side == .white {
            self.blackCapturedPieces = self.blackCapturedPieces.appendAndSort(piece: piece)
        } else {
            self.whiteCapturedPieces = self.whiteCapturedPieces.appendAndSort(piece: piece)
        }
    }
    private mutating func removeRecordedMove() {
        if !pgn.isEmpty {
            pgn.removeLast()
            fullMoveNumber -= 1
        }
    }
    private mutating func changeCastlingRights(after move: Move) {
        let piece = move.piece
        let start = move.start
        let side = piece.side
        if piece.type == .king {
            changeCastlingRights(side, queenSide: false, kingSide: false)
        } else if piece.type == .rook {
            if (side == .white && start.rankNum == 1)
            || (side == .black && start.rankNum == 8) {
                if start.fileLetter == Character("A") {
                    changeCastlingRights(side, queenSide: false)
                }
                if start.fileLetter == Character("H") {
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
    // MARK: - Static
    static var promotionTestGame: Game {
        do {
            return try FEN.shared.makeGame(from: "rnbqk1nr/ppppp1P1/5p2/8/8/8/PPPPPPP1/RNBQKBNR/ w KQkq - 0 5")
        } catch {
            print("ERROR: FEN error \(error)")
        }
        return Game()
    }
    static var checkTestGame: Game {
        do {
            return try FEN.shared.makeGame(from: "rnb1kbnr/pppp2pp/5p2/4P3/7q/6P1/PPPPP2P/RNBQKBNR/ w KQkq - 0 4")
        } catch {
            print("ERROR: FEN error \(error)")
        }
        return Game()
    }
    static var enPassantTestGame: Game {
        do {
            return try FEN.shared.makeGame(from: "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR/ b KQkq - 0 3")
        } catch {
            print("ERROR: FEN error \(error)")
        }
        return Game()
    }
}
