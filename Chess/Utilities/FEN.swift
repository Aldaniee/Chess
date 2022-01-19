//
//  FEN.swift
//  Forsych-Edwards Notation
//  Chess
//
//  Created by Aidan Lee on 1/18/22.
//

import Foundation

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
    
    func makeString(from board: [[Tile]]) -> String {
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
