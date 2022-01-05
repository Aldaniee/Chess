//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class Game: ObservableObject {
    @Published private var board = Board()
    
    var turn = Side.white
    var winner: Side?
    
    init() {
        newGame()
    }
    
    func newGame() {
        board.setupPieces()
        turn = Side.white
    }
    
    func selectTile(_ selection: Coordinate) {
        if let oldSelection = board.selectedTileCoordinate {
            let sameSelection = oldSelection == selection
            if sameSelection {
                board.deselect()
            }
            else {
                if let movingPiece = board.getPieceFromSelectedTile() {
                    if movingPiece.side == turn {
                        let moves = movingPiece.allPossibleMoves(from: oldSelection, board: board)
                        if moves.contains(selection) {
                            var capturedPiece = board.moveSelection(to: selection)
                            
                            // special case of En passant rule
                            // if a pawn moves diagonal and does not land on a pawn it must be capturing en passant
                            if movingPiece.type == .pawn && capturedPiece == nil && oldSelection.isDiagonal(from: selection) {
                                capturedPiece = board.removePiece(Coordinate(rankIndex: oldSelection.rankIndex, fileIndex: selection.fileIndex))
                            }
                            nextTurn()
                        }
                    }
                }
            }
        }
        board.selectTile(selection)
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
    }
}
