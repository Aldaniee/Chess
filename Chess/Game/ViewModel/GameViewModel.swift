//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    
    @Published private (set) var game = Game()

    // MARK: - Accessors
    var boardArray: [Tile] {
        Array(game.board.joined())
    }
}