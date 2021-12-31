//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published private var board = Board()
    
    func selectTile(_ selection: Coordinate) {
        let oldSelection = board.selectedTileCoordinate
        if oldSelection == selection {
            board.deselect()
        }
        else {
            if board.isMoveOption(selection) {
                board.moveSelection(to: selection)
            } else {
                board.selectTile(selection)
            }
        }
    }
    func asArray() -> Array<Tile> {
        board.asArray()
    }
    func selectedTile() -> Coordinate? {
        return board.selectedTileCoordinate
    }
}
