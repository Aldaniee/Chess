//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class Game: ObservableObject {
    @Published private var board = Board()
    
    private (set) var turn = Side.white
    
    init() {
        newGame()
    }
    
    func newGame() {
        board.setupPieces()
        turn = Side.white
    }
    
    
    /// Checks if the side whose turn it is is in check
    /// - Parameters:
    ///   - state: Board state to check
    ///   - turn: Side whose turn it is
    /// - Returns: if the side whose turn it is is in check
    func inCheck(_ state: Board, _ turn: Side) -> Bool {
        // define sides
        let kingSide = turn
        let attackingSide = kingSide.opponent

        guard let kingTile = state.getKingTile(color: turn) else { print("ERROR: No king on board"); return false }

        let attackingTiles = state.getAllTilesWithPieces(of: attackingSide)
        for tile in attackingTiles {
            guard let piece = tile.piece else { print("ERROR: Tile needs piece"); return false}
            let moves = piece.threatsCreated(from: tile.coordinate, board)
            for move in moves {
                if move == kingTile.coordinate {
                    return true
                }
            }
        }
        return false
    }
    
    func selectTile(_ selection: Coordinate) {
        if let oldSelection = board.selectedTileCoordinate {
            let sameSelection = oldSelection == selection
            if sameSelection {
                board.deselect()
            }
            else {
                let newSelection = selection
                if let movingPiece = board.getPieceFromSelectedTile() {
                    if movingPiece.side == turn {
                        move(movingPiece, from: oldSelection, to: newSelection)
                    }
                }
            }
        }
        board.selectTile(selection)
    }
    
    private func legalMoves(from location: Coordinate, with piece: Piece) -> [Coordinate]{
        var moves = piece.allPossibleMoves(from: location, board)
        
        // Prune moves that move into check
        for move in moves {
            var newState = board.copy()
            _ = newState.movePiece(from: location, to: move)
            if inCheck(newState, turn) {
                moves.removeAll(where: { $0 == move })
            }
        }
        return moves
    }
    
    private func move(_ piece: Piece, from location: Coordinate, to destination: Coordinate) {
        let moves = legalMoves(from: location, with: piece)
        
        if moves.contains(destination) {
            var capturedPiece = board.moveSelectedPiece(to: destination)
            
            // En passant special case
            // if a pawn moves diagonal and does not land on a pawn it must be capturing a pawn via en passant
            if piece.type == .pawn && capturedPiece == nil && location.isDiagonal(from: destination) {
                capturedPiece = board.removePiece(Coordinate(rankIndex: location.rankIndex, fileIndex: destination.fileIndex))
            }
            nextTurn()
        }
    }
    
    private func nextTurn() {
        turn = turn == .white ? .black : .white
    }
    
    func asArray() -> Array<Tile> {
        board.asArray()
    }
    func selectedTile() -> Coordinate? {
        return board.selectedTileCoordinate
    }
    enum Side {
        case white
        case black
        
        var opponent: Side {
            switch self {
            case .white:
                return .black
            case .black:
                return .white
            }
        }
        
        var abbreviation: String {
            switch self {
            case .white:
            return "w"
            case .black:
            return "b"
            }
        }
    }
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
}
