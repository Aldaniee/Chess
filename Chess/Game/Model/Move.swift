//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

enum MoveError: Error {
    case invalidMoveNotation, invalidPieceCharacterNotation, pieceNotFound
}

struct Move : Equatable {
    
    var start: Coordinate
    
    var end: Coordinate
    
    var piece: Piece
    
    var capturedPiece: Piece?
    
    var isCastling: Bool
    
    var promotesTo: Piece?
    
    var isReversible: Bool
    
    init(_ game: Game, from start: Coordinate, to end: Coordinate, promotesTo: Piece? = nil) {
        self.start = start
        self.end = end
        self.piece = game.getPiece(start)!
        self.capturedPiece = game.getPiece(end)
        self.isCastling = piece.type == .king && start.distance(to: end) != 1
        self.isReversible = !(piece.type == .pawn || isCastling)
        self.promotesTo = promotesTo
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
extension Move {
    init(_ game: Game, moveNotation: String) throws {
        var promotesTo: Piece? = nil
        var start: Coordinate
        var end: Coordinate
        
        var characterArray = Array(moveNotation)
        let isCapturing = characterArray.contains(where: {$0 == "x"})
        characterArray.removeAll(where: {$0 == "x"})
        characterArray.removeAll(where: {$0 == "+"})
        let endRankNum = characterArray.removeLast()
        let endFileLetter = characterArray.removeLast()
        
        var startFileLetter: Character? = nil
        var startRankNum: Int? = nil

        var type: PieceType
        
        if characterArray.isEmpty {
            type = PieceType.pawn
        } else if let pieceType = PieceType(rawValue: "\(characterArray.first!)") {
            type = pieceType
            characterArray.removeFirst()
        } else {
            print("\(characterArray.first!)")
            throw MoveError.invalidMoveNotation
        }

        end = Coordinate(notation: "\(endFileLetter)\(endRankNum)")
        
        for characterLeft in characterArray {
            if characterLeft.isLowercase {
                startFileLetter = characterLeft
            } else {
                if let rankNum = Int(characterLeft.description) {
                    startRankNum = rankNum
                } else {
                    throw MoveError.invalidMoveNotation
                }
            }
        }

        switch type {
        case .pawn:
            let forward = game.turn == .white ? Coordinate.Direction.upRank : Coordinate.Direction.downRank
            let backward = forward.opposite
            if isCapturing {
                start = Coordinate(notation: "\(startFileLetter!)\(backward.compute(end)!.rankNum)")
                self.init(game, from: start, to: end, promotesTo: promotesTo)
                return
            } else {
                end = Coordinate(notation: moveNotation)
                if let backOne = backward.compute(end) {
                    if game.getPiece(backOne) != nil {
                        start = backOne
                    } else {
                        start = backward.compute(backOne)!
                    }
                    self.init(game, from: start, to: end, promotesTo: promotesTo)
                    return
                }
            }
        case .king, .queen, .rook, .knight, .bishop:
            do {
                start = try Move.getStartCoordinates(game, type: type, fileLetter: startFileLetter, rankNum: startRankNum, end: end)
                self.init(game, from: start, to: end, promotesTo: promotesTo)
                return
            } catch {
                throw error
            }
        }

        throw MoveError.invalidMoveNotation
    }
    
    static func getStartCoordinates(_ game: Game, type: PieceType, fileLetter: Character? = nil, rankNum: Int? = nil, end: Coordinate) throws -> Coordinate {
        let tiles = game.getAllTilesWithPieces(game.turn)
        for tile in tiles {
            if tile.piece!.type == type {
                if tile.piece!.possibleMoves(from: tile.coordinate, game).contains(where: { $0.end == end }) {
                    
                    switch (fileLetter != nil, rankNum != nil) {
                        case (true, false):
                            if fileLetter == tile.coordinate.fileLetter {
                                return tile.coordinate
                            }
                        case (false, true):
                            if rankNum == tile.coordinate.rankNum {
                                return tile.coordinate
                            }
                        case (true, true):
                            if tile.coordinate == Coordinate(fileLetter: fileLetter!, rankNum: rankNum!) {
                                return tile.coordinate
                            }
                        default:
                            return tile.coordinate
                    }
                }
            }
        }
        throw MoveError.pieceNotFound
    }
}
