//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

extension Board: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case state
        case turn
        case id
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let state = try values.decode(String.self, forKey: .state)
        id = try values.decode(UUID.self, forKey: .id)
        turn = try values.decode(Side.self, forKey: .state)
        gameBoard = FEN.shared.makeBoard(from: state)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let state = FEN.shared.makeString(from: gameBoard)
        try container.encode(state, forKey: .state)
        try container.encode(id, forKey: .id)
        try container.encode(turn.rawValue, forKey: .turn)
    }
}

struct Board {
    
    private (set) var gameBoard = [[Tile]]()
    var turn = Side.white
    var id: UUID?
    
    init() {
        setupBoard()
    }
    init(_ gameBoard: [[Tile]]) {
        self.gameBoard = gameBoard
        turn = Side.white
    }
    // MARK: - Board Changing Actions
    mutating func setupBoard(from fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") {
        gameBoard = FEN.shared.makeBoard(from: fen)
    }
    private mutating func setPiece(_ piece: Piece?, _ coordinate: Coordinate) {
        gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    private mutating func putPiece(_ piece: Piece?, _ coordinate: Coordinate) -> Piece? {
        let oldPiece = getPiece(from: coordinate)
        setPiece(piece, coordinate)
        return oldPiece
    }
    mutating func removePiece(_ coordinate: Coordinate) -> Piece? {
        putPiece(nil, coordinate)
    }
    
    mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        print(FEN.shared.makeString(from: gameBoard))
        if let piece = getPiece(from: start) { // ensure a piece is on that tile
            let capturedPiece = putPiece(piece, end)
            markPieceAsMoved(at: end)
            _ = removePiece(start)
            return capturedPiece
        }
        return nil
    }
    
    mutating func markPieceAsMoved(at coordinate: Coordinate) {
        if getPiece(from: coordinate) != nil {
            gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece!.hasMoved = true
        }
    }
    
    // MARK: - Access Functions
    func getPiece(from coordinate: Coordinate) -> Piece? {
        gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece
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
            print("ERROR: No \(side.abbreviation)_king found on the board")
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
        return Array(gameBoard.joined())
    }
    
    func copy() -> Board {
        return Board(gameBoard)
    }
    
    func debugGameBoard() {
        for file in gameBoard {
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
