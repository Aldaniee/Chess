//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

enum PieceType : String {
    case pawn = "P"
    case rook = "R"
    case knight = "N"
    case bishop = "B"
    case king = "K"
    case queen = "Q"
    
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
}

protocol Piece {
    func allPossibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    var type: PieceType { get }
    var side: Side { get }
    var id: Int { get }
    var points: Int { get}
}

extension Piece {
    var image: Image {
        let assetName = "\(side.rawValue)_\(type.name)_shadow"
        return Image(assetName)
    }
    var imageNoShadow: Image {
        let assetName = "\(side.rawValue)_\(type.name)"
        return Image(assetName)
    }
    func getMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for potentialMove in threatsCreated(from: start, game) {
            
            if !game.isOccupied(potentialMove, side) && !game.doesMoveIntoCheck(from: start, to: potentialMove) {
                let move = Move(game, from: start, to: potentialMove)
                moves.append(move)
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
    
    func threatsCreated(from start: Coordinate, _ board: Game) -> [Coordinate] {
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
    
    func allPossibleMoves(from start: Coordinate, _ board: Game) -> [Move] {
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
