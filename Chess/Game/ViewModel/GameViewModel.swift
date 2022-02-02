//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    
    @Published private (set) var game: Game
    
    init(_ game: Game = Game()) {
        self.game = game
    }
    
    // MARK: - Accessors
    var boardArray: [Tile] {
        Array(game.board.joined())
    }
}
