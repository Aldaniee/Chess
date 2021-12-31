//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published private var board = Board()
    
    func selectTile(_ coordinate: Coordinate) {
        board.setSelectedTile(coordinate: coordinate)
    }
    func asArray() -> Array<Tile> {
        board.asArray()
    }
    func selectedTile() -> Coordinate? {
        return board.coordsOfOneAndOnlySelectedTile
    }
}
