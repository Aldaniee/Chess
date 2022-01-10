//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

enum PieceType {
    case pawn
    case rook
    case knight
    case bishop
    case king
    case queen
    
    var name: String {
        switch self {
        case .pawn:
            return "pawn"
        case .rook:
            return "rook"
        case .knight:
            return "knight"
        case .bishop:
            return "bishop"
        case .king:
            return "king"
        case .queen:
            return "queen"
        }
    }
    var abbreviation: Character {
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

protocol Piece {
    func allPossibleMoves(from start: Coordinate, _ board: Board) -> [Coordinate]
    func threatsCreated(from start: Coordinate, _ board: Board) -> [Coordinate]
    var hasMoved: Bool { get set }
    var type: PieceType { get }
    var side: Game.Side { get }    
}

extension Piece {
    var image: Image {
        let assetName = "\(side.abbreviation)_\(type.name)_shadow"
        return Image(assetName)
    }
    func getMovesFromThreats(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = threatsCreated(from: start, board)
        moves.forEach { move in
            if board.isOccupied(move, side) {
                moves.removeAll(where: {move == $0} )
            }
        }
        return moves
    }
}

// Examples: Rook, Bishop, Queen
protocol RecursivePiece : Piece {
    var moveType: MoveType { get }
}
extension RecursivePiece {
    
    func threatsCreated(from start: Coordinate, _ board: Board) -> [Coordinate] {
        var moves = [Coordinate]()
        for direction in moveType.directions {
            for move in start.allCoords(in: direction) {
                moves.append(move)
                if !board.isEmpty(move) {
                    break
                }
            }
        }
        return moves
    }
    
    func allPossibleMoves(from start: Coordinate, _ board: Board) -> [Coordinate] {
        self.getMovesFromThreats(from: start, board)
    }
}

enum MoveType {
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
