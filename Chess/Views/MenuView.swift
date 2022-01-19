//
//  MenuView.swift
//  Chess
//
//  Created by Aidan Lee on 1/19/22.
//

import SwiftUI

struct MenuView: View {
    
    @StateObject var viewModel = NetworkManager()
    
    var body: some View {
        NavigationView {
            List {
                Button {
                    Task {
                        await viewModel.newGame()
                    }
                } label: {
                    Text("Create Game")
                }
                ForEach(viewModel.boards) { board in

                    Button {
                        
                    } label: {
                        Text(board.id?.description ?? "")
                    }
                }
            }
            
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.fetchGames()
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
