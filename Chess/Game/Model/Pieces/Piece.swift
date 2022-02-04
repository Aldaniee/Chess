//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

enum MoveSet {
    case verticalHorizontal
    case diagonal
    case both
    var directions: [Coordinate.Direction] {
        let diagonal: [Coordinate.Direction] = [.upRankUpFile, .upRankDownFile, .downRankUpFile, .downRankDownFile]
        let verticalHorizontal: [Coordinate.Direction] = [.upRank, .downRank, .upFile, .downFile]
        switch self {
        case .verticalHorizontal:
            return verticalHorizontal
        case .diagonal:
            return diagonal
        case .both:
            return verticalHorizontal + diagonal
        }
    }
}
// MARK: - Implementations: King, Knight, Pawn, RecursivePieces
protocol Piece {
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    var type: PieceType { get }
    var side: Side { get }
    var id: Int { get }
    var points: Int { get}
}
extension Piece {
    var image: Image {
        return Image("\(side.rawValue)_\(type.rawValue)_svg_withShadow")
    }
    var imageNoShadow: Image {
        return Image("\(side.rawValue)_\(type.rawValue)_svg_NoShadow")
    }
    func possibleMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for end in threatsCreated(from: start, game) {
            if !game.isOccupied(at: end, by: side) && !game.isMovingIntoCheck(from: start, to: end) {
                let move = Move(game, from: start, to: end)
                moves.append(move)
            }
        }
        return moves
    }
}

// MARK: - Implementations: Rook, Bishop, Queen
protocol RecursivePiece : Piece {
    var moveType: MoveSet { get }
}
extension RecursivePiece {
    
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        var moves = [Coordinate]()
        for direction in moveType.directions {
            for move in start.allCoords(in: direction) {
                moves.append(move)
                if !game.isEmpty(move) {
                    break
                }
            }
        }
        return moves
    }
    
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move] {
        self.possibleMovesFromThreats(from: start, game)
    }
}

enum PieceType : String {
    case pawn, king, queen, rook, bishop, knight
    
    var abbreviation: String {
        switch self {
        case .pawn:
            return "P"
        case .rook:
            return "R"
        case .knight:
            return "N"
        case .bishop:
            return "B"
        case .king:
            return "K"
        case .queen:
            return "Q"
        }
    }
}
