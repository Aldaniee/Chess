//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var viewModel: GameViewModel = GameViewModel()
    
    let boardWidth = UIScreen.main.bounds.width
    let captureTrayHeight = CGFloat(40)
    let pgnDisplayHeight = CGFloat(100)
    let pgnMode = false
    
    var tileWidth: CGFloat {
        boardWidth / CGFloat(8)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                viewModel.newGame()
            } label: {
                Text("New Game")
            }
            BoardView(viewModel: viewModel, tileWidth: tileWidth)
            .frame(
                width: boardWidth,
                height: boardWidth,
                alignment: .center
            )
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
