//
//  NetworkManager.swift
//  Chess
//
//  Created by Aidan Lee on 1/19/22.
//

import Foundation
import SwiftUI

class NetworkManager {

    static let shared = NetworkManager()
    
    func fetchGames() async -> [Game]? {
        guard let url = URL(string: Constants.baseURL + Endpoints.games) else {
            print("Error fetchGames: \(HttpError.badURL)")
            return nil
        }
        
        do {
            return try await HttpClient.shared.fetch(url: url)
        } catch {
            print("Error fetchGames: \(error)")
            return nil
        }
    }
    
    func fetchGame(_ board: Game) async -> Game? {
        guard let url = URL(string: (Constants.baseURL + Endpoints.games + "/\(board.id)")) else {
            print("Error fetchGame: \(HttpError.invalidURL)")
            return nil
        }
        do {
            return try await HttpClient.shared.fetchSingle(url: url)
        }
        catch {
            print("Error fetchGame: \(error)")
            return nil
        }
    }
    
    func pushGame(_ board: Game) async {
        let urlString = Constants.baseURL + Endpoints.games
        
        guard let url = URL(string: urlString) else {
            print("Error pushGame: \(HttpError.badURL)")
            return
        }
        do {
            try await HttpClient.shared.send(to: url, object: board, httpMethod: .POST)
        } catch {
            print("Error pushGame: \(error)")
            return
        }
    }
    
    func updateGame(_ board: Game) async {
        let urlString = Constants.baseURL + Endpoints.games
        
        guard let url = URL(string: urlString) else {
            print("Error updateGame: \(HttpError.badURL)")
            return
        }
        do {
            try await HttpClient.shared.send(to: url, object: board, httpMethod: .PUT)
        } catch {
            print("Error updateGame: \(error)")
        }
    }
    
    func deleteGame(_ board: Game) async {        
        guard let url = URL(string: Constants.baseURL + Endpoints.games + "/\(board.id)") else {
            print("Error deleteGame: \(HttpError.badURL)")
            return
        }
        do {
            try await HttpClient.shared.send(to: url, object: board, httpMethod: .DELETE)
        } catch {
            print("Error deleteGame: \(error)")
        }
    }
}
