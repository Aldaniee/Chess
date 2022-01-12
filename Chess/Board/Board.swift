//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

struct Board {
    
    private (set) var gameBoard = [[Tile]]()
    private (set) var selectedTileCoordinate: Coordinate? = nil

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
            setPiece(Pawn(.white), Coordinate(fileLetter: index.toLetterAtAlphabeticalIndex(), rankNum: 2))
        }
        setPiece(King(.white), Coordinate(fileLetter: "E", rankNum: 1))
        setPiece(Rook(.white), Coordinate(fileLetter: "A", rankNum: 1))
        setPiece(Rook(.white), Coordinate(fileLetter: "H", rankNum: 1))
        setPiece(Knight(.white), Coordinate(fileLetter: "B", rankNum: 1))
        setPiece(Knight(.white), Coordinate(fileLetter: "G", rankNum: 1))
        setPiece(Bishop(.white), Coordinate(fileLetter: "C", rankNum: 1))
        setPiece(Bishop(.white), Coordinate(fileLetter: "F", rankNum: 1))
        setPiece(Queen(.white), Coordinate(fileLetter: "D", rankNum: 1))
        let baseIndex = Constants.dimensions + 1
        
        for index in 0..<Constants.dimensions {
            setPiece(Pawn(.black), Coordinate(fileLetter: index.toLetterAtAlphabeticalIndex(), rankNum: baseIndex-2))
        }
        setPiece(King(.black), Coordinate(fileLetter: "E", rankNum: baseIndex-1))
        setPiece(Rook(.black), Coordinate(fileLetter: "A", rankNum: baseIndex-1))
        setPiece(Rook(.black), Coordinate(fileLetter: "H", rankNum: baseIndex-1))
        setPiece(Knight(.black), Coordinate(fileLetter: "B", rankNum: baseIndex-1))
        setPiece(Knight(.black), Coordinate(fileLetter: "G", rankNum: baseIndex-1))
        setPiece(Bishop(.black), Coordinate(fileLetter: "C", rankNum: baseIndex-1))
        setPiece(Bishop(.black), Coordinate(fileLetter: "F", rankNum: baseIndex-1))
        setPiece(Queen(.black), Coordinate(fileLetter: "D", rankNum: baseIndex-1))
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
    func getKingTile(_ side: Game.Side) -> Tile? {
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
            return getPiece(from: selectedTileCoordinate!)
        }
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
                print(tile.id, terminator: "")
            }
        }
    }
    struct Constants {
        static let dimensions = 8
        static let maxIndex = dimensions - 1
    }
    
}
