//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    @Environment(\.colorScheme) var colorScheme

    var primaryColor: Color {
        colorScheme == .light ? .black : .white
    }
    var secondaryColor: Color {
        colorScheme == .light ? .white : .black
    }
    var colors: (primary: Color, secondary: Color) {
        (primaryColor, secondaryColor)
    }
    
    @ObservedObject var viewModel = GameViewModel()
    
    let boardWidth = UIScreen.main.bounds.width
    
    var tileWidth: CGFloat {
        boardWidth / CGFloat(8)
    }

    var body: some View {
        NavigationView {
            VStack {
                BoardView(viewModel: viewModel, tileWidth: tileWidth, boardWidth: boardWidth)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Chess").font(.headline)
                        Text("Pass & Play").font(.subheadline)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("New Game") {
                        viewModel.newGame()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    let display = viewModel.boardFlipsOnMove
                    ? "Flips On Move"
                    : "Stationary"
                    Button(display) {
                        viewModel.toggleBoardFlipping()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
