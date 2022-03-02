//
//  Move.swift
//  Chess
//
//  Created by Aidan Lee on 1/10/22.
//

import Foundation

enum MoveError: Error {
    case invalidMoveNotation, pieceNotFound
}

struct Move : Equatable {
    
    var start: Coordinate
    
    var end: Coordinate
    
    var piece: Piece
    
    var capturedPiece: Piece?
    
    var promotesTo: Piece?
    
    var isCastling: Bool {
        piece.type == .king && start.distance(to: end) != 1
    }
    
    var isReversible: Bool {
        !(piece.type == .pawn || isCastling)
    }
    
    init(_ game: Game, from start: Coordinate, to end: Coordinate, promotesTo: Piece? = nil) {
        self.start = start
        self.end = end
        self.piece = game.getPiece(start)!
        self.capturedPiece = game.getPiece(end)
        self.promotesTo = promotesTo
    }
    init(_ game: Game, moveNotation: String) throws {
        self = try Move.buildMove(game, moveNotation: moveNotation)
    }
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
}
extension Move {
    private func disambiguousMoveString(_ game: Game) -> String {
        var notation = ""
        var coordinates = [Coordinate]()
        let tiles = game.getAllTilesWithPieces(game.turn)
        for tile in tiles {
            if tile.piece!.type == piece.type {
                if tile.piece!.possibleMoves(game).contains(where: { $0.end == end && $0.start != start }) {
                    coordinates.append(tile.coordinate)
                }
            }
        }
        for coordinate in coordinates {
            if start.fileLetter == coordinate.fileLetter {
                notation.append(start.fileLetter)
            }
            if start.rankNum == coordinate.rankNum {
                notation.append("\(start.rankNum)")
            }
        }
        return notation
    }
    func asNotation(_ game: Game) -> String {
        
        // TODO: Doesn't cover checkmate
        
        if isCastling {
            if start.fileIndex < end.fileIndex {
                return "O-O"
            } else {
                return "O-O-O"
            }
        }
        var notation = ""
        if piece.type == .pawn {
            if capturedPiece != nil {
                notation.append(start.fileLetter)
                notation.append("x")
                notation.append(end.fileLetter)
            } else {
                notation.append(end.notation)
            }
        } else {
            notation.append(piece.type.rawValue)
            notation.append(disambiguousMoveString(game))
            if capturedPiece != nil {
                notation.append("x")
            }
            notation.append(end.notation)
        }
        
        var copy = game.copy()
        copy.makeMove(self)
        if copy.isCheck() {
            notation.append("+")
        }
        
        return notation
    }
    private static func buildMove(_ game: Game, moveNotation: String) throws -> Move {
        var promotesTo: Piece? = nil
        
        var characterArray = Array(moveNotation)
        let isCapturing = characterArray.contains(where: {$0 == "x"})
        characterArray.removeAll(where: {$0 == "x"})
        characterArray.removeAll(where: {$0 == "+"})
        characterArray.removeAll(where: {$0 == "#"})

        if characterArray.contains(where: {$0 == "="}) {
            promotesTo = PieceType(rawValue: characterArray.removeLast().description)?.makePiece(game.turn)
            characterArray.removeLast()
        }
        
        if moveNotation == "O-O-O" {
            let kingTile = try game.getKingTile(game.turn)
            let start = kingTile.coordinate
            if let end = start.downFile()?.downFile() {
                return Move(game, from: kingTile.coordinate, to: end)
            }
            throw MoveError.invalidMoveNotation
        }
        else if moveNotation == "O-O" {
            let kingTile = try game.getKingTile(game.turn)
            let start = kingTile.coordinate
            if let end = start.upFile()?.upFile() {
                return Move(game, from: kingTile.coordinate, to: end)
            }
            throw MoveError.invalidMoveNotation
        }
        
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

        let end = Coordinate(notation: "\(endFileLetter)\(endRankNum)")
        
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

        do {
            let start = try getStartCoordinates(game, type: type, fileLetter: startFileLetter, rankNum: startRankNum, end: end, isCapturing: isCapturing)
            return Move(game, from: start, to: end, promotesTo: promotesTo)
        } catch {
            throw error
        }
    }
    private static func getStartCoordinates(_ game: Game, type: PieceType, fileLetter: Character? = nil, rankNum: Int? = nil, end: Coordinate, isCapturing: Bool) throws -> Coordinate {
        if type == .pawn {
            let forward = game.turn == .white ? Coordinate.Direction.upRank : Coordinate.Direction.downRank
            let backward = forward.opposite
            if isCapturing {
                return Coordinate(notation: "\(fileLetter!)\(backward.next(end)!.rankNum)")
            } else {
                if let backOne = backward.next(end) {
                    if game.getPiece(backOne) != nil {
                        return backOne
                    } else {
                        return backward.next(backOne)!
                    }
                }
            }
        }
        
        let tiles = game.getAllTilesWithPieces(game.turn)
        for tile in tiles {
            if tile.piece!.type == type {
                if tile.piece!.possibleMoves(game).contains(where: { $0.end == end }) {
                    
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
