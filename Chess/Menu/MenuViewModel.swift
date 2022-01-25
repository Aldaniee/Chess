//
//  MenuViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 1/21/22.
//

import Foundation
import SwiftUI

@MainActor class MenuViewModel: ObservableObject {

    @Published private (set) var boards = [Game]()

    // MARK: - Intents
    
    func fetchGames() async {
        do {
            if let games = await NetworkManager.shared.fetchGames() {
                DispatchQueue.main.async {
                    self.boards = games
                }
            }
        }
    }
    func fetchGame(_ board: Game) async {
        do {
            if let game = await NetworkManager.shared.fetchGame(board) {
                DispatchQueue.main.async {
                    if let i = self.boards.firstIndex(where: {$0.id == game.id}) {
                        self.boards[i] = game
                    }
                    else {
                        self.boards.append(game)
                    }
                }
            }
        }
    }
    func createGame() async {
        let board = Game()
        self.boards.append(board)
        await NetworkManager.shared.pushGame(board)
        await fetchGame(board)
    }
    
    func deleteGame(_ index: Int) async {
        let board = self.boards[index]
        await NetworkManager.shared.deleteGame(board)
        DispatchQueue.main.async {
            self.boards.removeAll(where: {$0.id == board.id})
        }
    }
    
}
