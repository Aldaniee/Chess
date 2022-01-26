//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

extension Game: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case state
        case turn
        case id
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let state = try values.decode(String.self, forKey: .state)
        self = try FEN.shared.makeGame(from: state)
        id = try values.decode(UUID.self, forKey: .id)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let state = FEN.shared.makeString(from: self)
        try container.encode(state, forKey: .state)
        try container.encode(id, forKey: .id)
    }
}

struct FullMove {
    var white: Move
    var black: Move?
    
    var display: String {
        "\(white.fullAlgebraicNotation) \(black?.fullAlgebraicNotation ?? "") "
    }
}

struct Game {

    var id = UUID()
    
    private (set) var board = [[Tile]]()
    var turn = Side.white
    var whiteCanCastle = (queenSide: true, kingSide: true)
    var blackCanCastle = (queenSide: true, kingSide: true)

    var enPassantTarget: Coordinate? = nil
    var halfMoveClock = 0 // used for 50 move rule
    var fullMoveNumber = 1 // move counter
    
    var winner: String?
    
    var whiteCapturedPieces = [(piece: Piece, count: Int)]()
    var blackCapturedPieces = [(piece: Piece, count: Int)]()
    
    private (set) var pgn = [FullMove]() // portable game notation
    
    var pgnString: String {
        var pgnString = ""
        for index in 0..<pgn.count {
            pgnString.append("\(index+1). ")
            pgnString.append(pgn[index].display)
        }
        return pgnString
    }
    
    func canLongCastle(_ side: Side) -> Bool {
        return side == .white ? whiteCanCastle.queenSide :  blackCanCastle.queenSide
    }
    
    func canShortCastle(_ side: Side) -> Bool {
        return side == .white ? whiteCanCastle.kingSide :  blackCanCastle.kingSide
    }
    
    init() {
        setupBoard()
        winner = nil
        pgn = [FullMove]()
        whiteCapturedPieces = [(piece: Piece, count: Int)]()
        blackCapturedPieces = [(piece: Piece, count: Int)]()
    }
    init(_ gameBoard: [[Tile]]) {
        self.board = gameBoard
        turn = Side.white
        winner = nil
        pgn = [FullMove]()
        whiteCapturedPieces = [(piece: Piece, count: Int)]()
        blackCapturedPieces = [(piece: Piece, count: Int)]()
    }
    // MARK: - Board Changing Actions
    mutating func setupBoard(from fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") {
        board = FEN.shared.makeBoard(from: fen)
    }
    private mutating func setPiece(_ piece: Piece?, _ coordinate: Coordinate) {
        board[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
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
    
    mutating func capture(piece: Piece) {
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
    mutating func removeRecordedMove() {
        if let fullMoveToRemove = pgn.last {
            if turn == .white {
                let fullMove = FullMove(white: pgn.last!.white, black: nil)
                pgn.removeLast()
                pgn.append(fullMove)
            } else {
                pgn.removeLast()
                fullMoveNumber -= 1
            }
        }
    }
    // MARK: - Access Functions
    func getPiece(from coordinate: Coordinate) -> Piece? {
        board[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece
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
    
    // Should never return nil as a king is always on the board
    func getKingTile(_ side: Side) -> Tile? {
        var king: Tile?
        asArray().forEach { tile in
            if let piece = tile.piece {
                if piece.side == side && piece.type == .king {
                    king = tile
                }
            }
        }
        if king == nil {
            print("ERROR: No \(side.rawValue)_king found on the board")
        }
        return king
    }
    func isOccupied(_ coordinate: Coordinate, _ side: Side) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == side
        }
        return false
    }
    func isEmpty(_ coordinate: Coordinate) -> Bool {
        return getPiece(from: coordinate) == nil
    }
    
    func asArray() -> Array<Tile> {
        return Array(board.joined())
    }
    
    func copy() -> Game {
        return Game(board)
    }
    
    func debugGameBoard() {
        for file in board {
            print()
            for tile in file {
                print(tile.coordinate.algebraicNotation, terminator: "")
            }
        }
    }
    struct Constants {
        static let dimensions = 8
        static let maxIndex = dimensions - 1
    }
    
}
