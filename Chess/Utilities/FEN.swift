//
//  FEN.swift
//  Forsych-Edwards Notation
//  Chess
//
//  Created by Aidan Lee on 1/18/22.
//

import Foundation

enum FENError: Error {
    case decodingError, encodingError
}

class FEN {
    static let shared = FEN()
    
    func makeBoard(from fen: String) -> [[Tile]] {
        var gameBoard = [[Tile]]()
        for _ in 0..<8 {
            gameBoard.append([Tile]())
        }
        let board = fen.components(separatedBy: "/")
        for rank in 0..<8 {
            var file = 0
            for letter in board[rank] {
                if letter.isNumber {
                    let numSpaces = Int(letter.description) ?? 0
                    for _ in 0..<numSpaces {
                        gameBoard[rank].append(Tile(Coordinate(rankIndex: 7-rank, fileIndex: file), nil))
                        file += 1
                    }
                } else {
                    let side = letter.isUppercase ? Side.white : Side.black
                    let piece = getPiece(from: letter.description, of: side)
                    gameBoard[rank].append(Tile(Coordinate(rankIndex: 7-rank, fileIndex: file), piece))
                    file += 1
                }
            }
        }
        return gameBoard
    }
    
    func makeString(from game: Game, withoutClocks: Bool = false) -> String {
        let piecePlacement = makeString(from: game.board)
        let activeColor = game.turn.rawValue
        let castlingAvailability = encodeCastlingAvailability(white: game.whiteCanCastle, black: game.blackCanCastle)
        let enPassantTargetSquare = game.enPassantTarget?.algebraicNotation ?? "-"
        if withoutClocks {
            return piecePlacement + " " + activeColor + " " + castlingAvailability + " " + enPassantTargetSquare
        }
        let halfMoveClock = "\(game.halfMoveClock)"
        let fullMoveClock = "\(game.fullMoveNumber)"
        return piecePlacement + " " + activeColor + " " + castlingAvailability + " " + enPassantTargetSquare + " " + halfMoveClock + " " + fullMoveClock
    }
    
    func makeGame(from string: String) throws -> Game {
        let fields = string.split(separator: " ")
        guard fields.count == 6 else {
            throw FENError.decodingError
        }
        var game = Game(makeBoard(from: fields[0].description))
        guard let side = Side(rawValue: fields[1].description) else {
            throw FENError.decodingError
        }
        game.turn = side
        let canCastle = decodeCastlingAvailability(from: fields[2].description)
        game.whiteCanCastle = canCastle.white
        game.blackCanCastle = canCastle.black
        let enPassantTargetSquare = fields[3].description
        if enPassantTargetSquare == "-" {
            game.enPassantTarget = nil
        }
        else {
            game.enPassantTarget = Coordinate(algebraicNotation: enPassantTargetSquare)
        }
        let halfMoveClock = fields[4].description
        game.halfMoveClock = Int(halfMoveClock) ?? 0
        let fullMoveNumber = fields[5].description
        game.fullMoveNumber = Int(fullMoveNumber) ?? 0
        return game
    }
    
    private func decodeCastlingAvailability(from fenSubstring: String ) -> (white: (queenSide: Bool, kingSide: Bool), black: (queenSide: Bool, kingSide: Bool)) {
        var white = (queenSide: false, kingSide: false)
        var black = (queenSide: false, kingSide: false)
        if fenSubstring != "-" {
            if fenSubstring.contains("Q") { white.queenSide = true }
            if fenSubstring.contains("K") { white.kingSide = true }
            if fenSubstring.contains("k") { black.kingSide = true }
            if fenSubstring.contains("q") { black.queenSide = true }
        }
        return (white, black)
    }
    
    private func encodeCastlingAvailability(white: (queenSide: Bool, kingSide: Bool), black: (queenSide: Bool, kingSide: Bool)) -> String {
        var castlingAvailability = ""
        if white.kingSide { castlingAvailability.append(contentsOf: "K") }
        if white.queenSide { castlingAvailability.append(contentsOf: "Q") }
        if black.kingSide { castlingAvailability.append(contentsOf: "k") }
        if black.queenSide { castlingAvailability.append(contentsOf: "q") }
        if castlingAvailability == "" { return "-" }
        return castlingAvailability
    }
    
    private func makeString(from board: [[Tile]]) -> String {
        var FENstring = ""
        for rank in 0..<board.count {
            var numEmpty = 0
            for tile in board[rank] {
                if let piece = tile.piece {
                    if numEmpty != 0 { FENstring += "\(numEmpty)" }
                    numEmpty = 0
                    let pieceLetter = piece.side == .white ? piece.type.rawValue.uppercased() : piece.type.rawValue.lowercased()
                    FENstring += pieceLetter
                } else {
                    numEmpty += 1
                }
            }
            if numEmpty != 0 { FENstring += "\(numEmpty)" }
            numEmpty = 0
            FENstring += "/"
        }
        return FENstring
    }
    
    func getPiece(from pieceChar: String, of side: Side) -> Piece {
        guard let pieceType = PieceType(rawValue: pieceChar.uppercased()) else {
            return Pawn(side)
        }
        switch pieceType {
        case .pawn:
            return Pawn(side)
        case .rook:
            return Rook(side)
        case .knight:
            return Knight(side)
        case .bishop:
            return Bishop(side)
        case .king:
            return King(side)
        case .queen:
            return Queen(side)
        }
    }
}
