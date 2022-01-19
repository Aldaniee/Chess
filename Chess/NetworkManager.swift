//
//  NetworkManager.swift
//  Chess
//
//  Created by Aidan Lee on 1/19/22.
//

import Foundation
import SwiftUI

class NetworkManager: ObservableObject {
    
    @Published private (set) var boards = [Board]()

    func fetchGames() async throws {
        let urlString = Constants.baseURL + Endpoints.games
        
        guard let url = URL(string: urlString) else {
            throw HttpError.badURL
        }
        
        let boardResponse: [Board] = try await HttpClient.shared.fetch(url: url)
        
        DispatchQueue.main.async {
            self.boards = boardResponse
        }
    }
    func newGame() async {
        let urlString = Constants.baseURL + Endpoints.games
        
        guard let url = URL(string: urlString) else {
            print("Error: \(HttpError.badURL)")
            return
        }
        boards.append(Board())
        do {
            try await HttpClient.shared.sendData(to: url, object: Board(), httpMethod: .POST)
            try await fetchGames()
        } catch {
            print("Error: \(error)")
        }
    }
    
}
