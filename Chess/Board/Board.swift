//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

struct Board {
    
    private (set) var gameBoard = [[Tile]]()
    private (set) var selectedTileCoordinate: Coordinate?

    init() {
        buildBoard()
    }
    init(_ gameBoard: [[Tile]]) {
        self.gameBoard = gameBoard
    }
    mutating func buildBoard() {
        for _ in 0...Constants.maxIndex {
            gameBoard.append(Array<Tile>())
        }
        for rank in 0...Constants.maxIndex {
            for file in 0...Constants.maxIndex {
                gameBoard[rank].append(Tile(Coordinate(rankIndex: Constants.maxIndex-rank, fileIndex: file), nil))
            }
        }
    }
    // MARK: - Board Changing Actions
    mutating func setupPieces() {
        for index in 0..<Constants.dimensions {
            setPiece(Pawn(side: .white), Coordinate(fileLetter: index.toLetterAtAlphabeticalIndex(), rankNum: 2))
        }
        setPiece(King(side: .white), Coordinate(fileLetter: "E", rankNum: 1))
        
        for index in 0..<Constants.dimensions {
            setPiece(Pawn(side: .black), Coordinate(fileLetter: index.toLetterAtAlphabeticalIndex(), rankNum: Constants.dimensions-1))
            setPiece(King(side: .black), Coordinate(fileLetter: "E", rankNum: 8))
        }
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
    mutating func selectTile(_ coordinate: Coordinate?) {
        selectedTileCoordinate = coordinate
    }
    
    mutating func deselect() {
        selectTile(nil)
    }
    
    mutating func moveSelectedPiece(to coordinate: Coordinate) -> Piece? {
        if let selectedCoord = selectedTileCoordinate { // ensure a tile is selected
            let capturedPiece = movePiece(from: selectedCoord, to: coordinate)
            selectedTileCoordinate = nil
            return capturedPiece
        }
        return nil
    }
    
    mutating func movePiece(from start: Coordinate, to end: Coordinate) -> Piece? {
        if let piece = getPiece(from: start) { // ensure a piece is on that tile
            let capturedPiece = putPiece(piece, end)
            _ = removePiece(start)
            return capturedPiece
        }
        return nil
    }
    
    // MARK: - Access Functions
    func getPiece(from coordinate: Coordinate) -> Piece? {
        gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    func getAllTilesWithPieces(of side: Game.Side) -> [Tile] {
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
    func getKingTile(color side: Game.Side) -> Tile? {
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
    func getNewStateFromMove(from start: Coordinate, to end: Coordinate) {
        return
    }
    
    func isOccupied(_ coordinate: Coordinate, _ side: Game.Side) -> Bool {
        if let piece = getPiece(from: coordinate) {
            return piece.side == side
        }
        return false
    }
    
    func getPieceFromSelectedTile() -> Piece? {
        if selectedTileCoordinate == nil {
            return nil
        }
        else {
            return getPieceFromCoords(selectedTileCoordinate!)
        }
    }
    func emptySquare(_ coordinate: Coordinate) -> Bool {
        return getPieceFromCoords(coordinate) == nil
    }
    func getPieceFromCoords(_ coordinate: Coordinate) -> Piece? {
        if !coordinate.isValid() {
            print("ERROR: Coordinate invalid:\(coordinate)")
            return nil
        }
        return gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece
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
                print(tile.id, terminator: "")
            }
        }
    }
    struct Constants {
        static let dimensions = 8
        static let maxIndex = dimensions - 1
    }
}
