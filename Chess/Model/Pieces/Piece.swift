//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

// MARK: - Implementations: King, Knight, Pawn, RecursivePieces
protocol Piece {
    // get all legal move options this piece has
    func possibleMoves(from start: Coordinate, _ game: Game) -> [Move]
    
    // get all coordinates this piece threatens
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate]
    
    var type: PieceType { get }
    var side: Side { get }
    var id: Int { get }
    var points: Int { get }
}
extension Piece {
    var image: Image {
        let assetName = "\(side.rawValue)_\(type)_svg_withShadow"
        return Image(assetName)
    }
    var imageNoShadow: Image {
        let assetName = "\(side.rawValue)_\(type)_svg_NoShadow"
        return Image(assetName)
    }
    
    func possibleMoves(_ game: Game) -> [Move] {
        return possibleMoves(from: getLocation(game), game)
    }
    func threatsCreated(_ game: Game) -> [Coordinate] {
        return threatsCreated(from: getLocation(game), game)
    }
    func possibleMovesFromThreats(from start: Coordinate, _ game: Game) -> [Move] {
        var moves = [Move]()
        for end in threatsCreated(from: start, game) {
            if !game.isOccupied(at: end, by: side) && !isMovingIntoCheck(game, from: start, to: end) {
                moves.append(Move(game, from: start, to: end))
            }
        }
        return moves
    }
    func isMovingIntoCheck(_ game: Game, from start: Coordinate, to end: Coordinate) -> Bool {
        var newState = game.copy()
        newState.makeMove(Move(game, from: start, to: end))
        return newState.isCheck()
    }
    private func getLocation(_ game: Game) -> Coordinate {
        guard let start = game.getAllTilesWithPieces(side).first(
            where: { $0.piece?.id == self.id }
        )?.coordinate else {
            print("ERROR: Piece not on board")
            return Coordinate(0, 0)
        }
        return start
    }
}

// MARK: - Implementations: Rook, Bishop, Queen
protocol RecursivePiece : Piece {
    var moveDirections: [Coordinate.Direction] { get }
}
extension RecursivePiece {
    
    func threatsCreated(from start: Coordinate, _ game: Game) -> [Coordinate] {
        var moves = [Coordinate]()
        for direction in moveDirections {
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
    case pawn = "P"
    case king = "K"
    case queen = "Q"
    case rook = "R"
    case knight = "N"
    case bishop = "B"
    
    func makePiece(_ side: Side) -> Piece {
        switch self {
        case .pawn:
            return Pawn(side)
        case .king:
            return King(side)
        case .queen:
            return Queen(side)
        case .rook:
            return Rook(side)
        case .knight:
            return Knight(side)
        case .bishop:
            return Bishop(side)
        }
    }
}
