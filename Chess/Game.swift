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
    var player1 = Side.white
    var player2 = Side.black
    
    init() {
        newGame()
    }
    
    func newGame() {
        board.setupPieces()
        
    }
    
    func selectTile(_ selection: Coordinate) {
        if let oldSelection = board.selectedTileCoordinate {
            let sameSelection = oldSelection == selection
            if sameSelection {
                board.deselect()
            }
            else {
                if let movingPiece = board.getPieceFromSelectedTile() {
                    let moves = movingPiece.allPossibleMoves(from: oldSelection, board: board)
                    if moves.contains(selection) {
                        var capturedPiece = board.moveSelection(to: selection)
                        
                        // special case of En passant rule
                        // if a pawn moves diagonal and does not land on a pawn it must be capturing en passant
                        if movingPiece.name == "pawn" && capturedPiece == nil && oldSelection.isDiagonal(from: selection) {
                            capturedPiece = board.removePiece(Coordinate(rankIndex: oldSelection.rankIndex, fileIndex: selection.fileIndex))
                        }
                        nextTurn()
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

}
