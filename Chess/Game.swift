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
    private (set) var winner : String?
    var boardArray: Array<Tile> {
        board.asArray()
    }
    var selectedTile: Coordinate? {
        board.selectedTileCoordinate
    }
    
    init() {
        newGame()
    }
    
    // MARK: - Intents
    func newGame() {
        board = Board()
        winner = nil
        turn = Side.white
        board.setupPieces()
    }
    
    func deselect() {
        board.deselect()
    }
    
    func selectTile(_ selection: Coordinate) {
        if !selection.isValid() {
            return
        }
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
    
    // MARK: - Private
    private func nextTurn() {
        turn = turn == .white ? .black : .white
        if hasNoMoves(turn) {
            if inCheck(board, turn) {
                winner = turn.opponent.name
            }
            else {
                winner = "draw"
            }
        }
    }
    
    private func hasNoMoves(_ side: Side) -> Bool {
        var result = true
        board.getAllTilesWithPieces(of: side).forEach { tile in
            if !legalMoves(from: tile).isEmpty {
                result = false
                return
            }
        }
        return result
    }
    
    private func move(_ piece: Piece, from start: Coordinate, to destination: Coordinate) {
        let moves = legalMoves(from: Tile(start, piece))
        
        if moves.contains(destination) {
            var capturedPiece = board.moveSelectedPiece(to: destination)
            
            // Castle
            if piece.type == .king && piece.hasMoved == false {
                
                // King-side/short castle
                if start.upFile()?.upFile() == destination {
                    if let rookLocation = start.upFile()?.upFile()?.upFile() {
                        _ = board.movePiece(from: rookLocation, to: start.upFile()!)
                    }
                }
                
                // Queen-side/long castle
                if start.downFile()?.downFile() == destination {
                    if let rookLocation = start.downFile()?.downFile()?.downFile()?.downFile() {
                        _ = board.movePiece(from: rookLocation, to: start.downFile()!)
                    }
                }
                
            }
            
            
            // En Passant Special Case
            // if a pawn moves diagonal and does not land on a pawn it must be capturing a pawn via en passant
            if piece.type == .pawn && capturedPiece == nil && start.isDiagonal(from: destination) {
                capturedPiece = board.removePiece(Coordinate(rankIndex: start.rankIndex, fileIndex: destination.fileIndex))
            }
            nextTurn()
        }
    }
    
    
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    private func legalMoves(from tile: Tile) -> [Coordinate] {
        if let piece = tile.piece {
            var moves = tile.piece!.allPossibleMoves(from: tile.coordinate, board)
            
            // Add castling moves
            if piece.type == .king
                && piece.hasMoved == false
                && !inCheck(board, turn) {
                // king side
                if let newRookCords = tile.coordinate.upFile(),
                   board.isEmpty(newRookCords),
                   let newKingCords = newRookCords.upFile(),
                   board.isEmpty(newKingCords),
                   let rookCords = newKingCords.upFile(),
                   let piece = board.getPiece(from: rookCords),
                   piece.type == .rook,
                   piece.hasMoved == false
                {
                    moves.append(newKingCords)
                }
                // queen side
                if let newRookCords = tile.coordinate.downFile(),
                   board.isEmpty(newRookCords),
                   let newKingCords = newRookCords.downFile(),
                   board.isEmpty(newKingCords),
                   let empty = newKingCords.downFile(),
                   board.isEmpty(empty),
                   let rookCords = empty.downFile(),
                   let piece = board.getPiece(from: rookCords),
                   piece.type == .rook,
                   piece.hasMoved == false
                {
                    moves.append(newKingCords)
                }
            }
            
            
            // Remove any moves that move into check
            for move in moves {
                var newState = board.copy()
                _ = newState.movePiece(from: tile.coordinate, to: move)
                if inCheck(newState, turn) {
                    moves.removeAll(where: { $0 == move })
                }
            }
            return moves
        }
        return [Coordinate]()
    }
    
    
    /// Checks if the side whose turn it is is in check
    /// - Parameters:
    ///   - state: Board state to check
    ///   - turn: Side whose turn it is
    /// - Returns: if the side whose turn it is is in check
    private func inCheck(_ state: Board, _ turn: Side) -> Bool {
        // define sides
        let kingSide = turn
        let attackingSide = kingSide.opponent
        
        guard let kingTile = state.getKingTile(kingSide) else { print("ERROR: No king on board"); return false }

        let attackingTiles = state.getAllTilesWithPieces(of: attackingSide)
        for tile in attackingTiles {
            guard let piece = tile.piece else { print("ERROR: Tile needs piece"); return false}
            let moves = piece.threatsCreated(from: tile.coordinate, state)
            for move in moves {
                if move == kingTile.coordinate {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Type Definitions

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
        var name: String {
            switch self {
            case .white:
                return "white"
            case .black:
                return "black"
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
