//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

struct Board {
    
    private (set) var gameBoard = Array<Array<Tile>>()
    private (set) var selectedTileCoordinate: Coordinate?

    init() {
        buildBoard()
        setupPieces()
    }
    mutating func buildBoard() {
        for _ in 0...Constants.maxIndex {
            gameBoard.append(Array<Tile>())
        }
        for rank in 0...Constants.maxIndex {
            for file in 0...Constants.maxIndex {
                gameBoard[rank].append(Tile(coordinate: Coordinate(rankIndex: Constants.maxIndex-rank, fileIndex: file), piece: nil))
            }
        }
    }
    // MARK: - Board Changing Actions
    mutating func setPiece(_ piece: Piece?, _ coordinate: Coordinate) {
        gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    mutating func putPiece(_ piece: Piece?, _ coordinate: Coordinate) -> Piece? {
        let oldPiece = getPiece(coordinate)
        setPiece(piece, coordinate)
        return oldPiece
    }
    mutating func removePiece(_ coordinate: Coordinate) -> Piece? {
        putPiece(nil, coordinate)
    }
    
    mutating func setupPieces() {
        for index in 0..<Constants.dimensions {
            setPiece(Pawn(isWhite: true), Coordinate(fileLetter: index.toLetterAtAlphabeticalIndex(), rankNum: 2))
        }
        
        for index in 0..<Constants.dimensions {
            setPiece(Pawn(isWhite: false), Coordinate(fileLetter: index.toLetterAtAlphabeticalIndex(), rankNum: Constants.dimensions-1))
        }
    }
    
    mutating func selectTile(_ coordinate: Coordinate?) {
        selectedTileCoordinate = coordinate
    }
    
    mutating func deselect() {
        selectTile(nil)
    }
    
    mutating func moveSelection(to coordinate: Coordinate) -> Piece? {
        if let selectedTile = selectedTileCoordinate { // ensure a tile is selected
            if let piece = getPieceFromSelectedTile() { // ensure a piece is on that tile
                let capturedPiece = putPiece(piece, coordinate)
                _ = removePiece(selectedTile)
                selectedTileCoordinate = nil
                return capturedPiece
            }
        }
        return nil
    }
    
    // MARK: - Access Functions
    func isMoveOption(_ end: Coordinate) -> Bool {
        var moves = [Coordinate]()
        if let pieceStart = selectedTileCoordinate { // ensure a tile is selected
            if let piece = getPieceFromSelectedTile() { // ensure a piece is on that tile
                moves = piece.allPossibleMoves(pieceStart)
            }
        }
        return moves.contains(end)

    }
    func getPiece(_ coordinate: Coordinate) -> Piece? {
        gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    func getPieceFromSelectedTile() -> Piece? {
        if selectedTileCoordinate == nil {
            return nil
        }
        else {
            return getPieceFromCoords(selectedTileCoordinate!)
        }
    }
    func getPieceFromCoords(_ coordinate: Coordinate) -> Piece? {
        return gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece
    }
    
    func asArray() -> Array<Tile> {
        return Array(gameBoard.joined())
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
