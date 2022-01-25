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


struct Game {

    var id = UUID()
    
    private (set) var board = [[Tile]]()
    var turn = Side.white
    var whiteCanCastle = (queenSide: true, kingSide: true)
    var blackCanCastle = (queenSide: true, kingSide: true)

    var enPassantTarget: Coordinate? = nil
    var halfMoveClock = 0 // used for 50 move rule
    var fullMoveNumber = 1 // move counter
    
    func canLongCastle(_ side: Side) -> Bool {
        return side == .white ? whiteCanCastle.queenSide :  blackCanCastle.queenSide
    }
    
    func canShortCastle(_ side: Side) -> Bool {
        return side == .white ? whiteCanCastle.kingSide :  blackCanCastle.kingSide
    }
    
    init() {
        setupBoard()
    }
    init(_ gameBoard: [[Tile]]) {
        self.board = gameBoard
        turn = Side.white
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
            let capturedPiece = putPiece(piece, end)
            _ = removePiece(start)
            changeCastlingRightsAfterMove(from: start, to: end)
            return capturedPiece
        }
        return nil
    }
    
    mutating func changeCastlingRightsAfterMove(from start: Coordinate, to end: Coordinate) {
        if let piece = getPiece(from: end) {
            let side = piece.side
            if piece.type == .king {
                if side == .white {
                    whiteCanCastle = (false, false)
                } else {
                    blackCanCastle = (false, false)
                }
            } else if piece.type == .rook {
                if side == .white {
                    if start.algebraicNotation == "A1" {
                        whiteCanCastle.queenSide = false
                    }
                    if start.algebraicNotation == "H1" {
                        whiteCanCastle.kingSide = false
                    }
                } else {
                    if start.algebraicNotation == "A8" {
                        blackCanCastle.queenSide = false
                    }
                    if start.algebraicNotation == "H8" {
                        blackCanCastle.kingSide = false
                    }
                }
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
    func isEmpty(_ coordinates: [Coordinate]) -> Bool {
        var result = true
        coordinates.forEach {
            if !isEmpty($0) {
                result = false
            }
        }
        return result
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
