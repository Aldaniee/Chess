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
    
    func fetchGames() async -> [Board]? {
        guard let url = URL(string: Constants.baseURL + Endpoints.games) else {
            print("Error: \(HttpError.badURL)")
            return nil
        }
        
        do {
            return try await HttpClient.shared.fetch(url: url)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func fetchGame(_ board: Board) async -> Board? {
        guard let url = URL(string: (Constants.baseURL + Endpoints.games + "/\(board.id)")) else {
            print("Error: \(HttpError.invalidURL)")
            return nil
        }
        do {
            return try await HttpClient.shared.fetchSingle(url: url)
        }
        catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func pushGame(_ board: Board) async {
        let urlString = Constants.baseURL + Endpoints.games
        
        guard let url = URL(string: urlString) else {
            print("Error: \(HttpError.badURL)")
            return
        }
        do {
            try await HttpClient.shared.send(to: url, object: board, httpMethod: .POST)
        } catch {
            print("Error: \(error)")
            return
        }
    }
    
    func updateGame(_ board: Board) async {
        let urlString = Constants.baseURL + Endpoints.games
        
        guard let url = URL(string: urlString) else {
            print("Error: \(HttpError.badURL)")
            return
        }
        do {
            try await HttpClient.shared.send(to: url, object: board, httpMethod: .PUT)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func deleteGame(_ board: Board) async {        
        guard let url = URL(string: Constants.baseURL + Endpoints.games + "/\(board.id)") else {
            print("Error: \(HttpError.badURL)")
            return
        }
        do {
            try await HttpClient.shared.send(to: url, object: board, httpMethod: .DELETE)
        } catch {
            print("Error: \(error)")
        }
    }
}
