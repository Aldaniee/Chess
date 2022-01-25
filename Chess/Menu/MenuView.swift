//
//  MenuView.swift
//  Chess
//
//  Created by Aidan Lee on 1/19/22.
//

import SwiftUI

struct MenuView: View {
    
    @StateObject var viewModel = MenuViewModel()
    var body: some View {
        NavigationView {
            List {
                Button {
                    Task {
                        await viewModel.createGame()
                    }
                } label: {
                    Text("Create Game")
                }
                ForEach(viewModel.boards) { board in
                    NavigationLink(destination: GameView(viewModel: GameViewModel(board))) {
                        Text(board.id.description)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Chess")
        }
        .onAppear {
            Task {
                await viewModel.fetchGames()
            }
        }
    }
    func delete(at offsets: IndexSet) {
        offsets.forEach { i in
            Task {
                await viewModel.deleteGame(i)
            }
        }

    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
