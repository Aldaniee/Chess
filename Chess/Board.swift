//
//  Board.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

struct Board {
    
    private (set) var gameBoard = Array<Array<Tile>>()
    private (set) var coordsOfOneAndOnlySelectedTile: Coordinate?
    
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
    mutating func addPiece(piece: Piece?, coordinate: Coordinate) {
        gameBoard[Constants.maxIndex-coordinate.rankIndex][coordinate.fileIndex].piece = piece
    }
    
    mutating func removePiece(coordinate: Coordinate) {
        addPiece(piece: nil, coordinate: coordinate)
    }
    
    mutating func setupPieces() {
        addPiece(piece: Pawn(isWhite: true), coordinate: Coordinate(fileLetter: "C", rankNum: 2))
    }
    
    mutating func setSelectedTile(coordinate: Coordinate) {
        if coordsOfOneAndOnlySelectedTile == coordinate {
            coordsOfOneAndOnlySelectedTile = nil
        }
        else {
            coordsOfOneAndOnlySelectedTile = coordinate
        }
    }
    
    
    // MARK: - Access Functions
    
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
