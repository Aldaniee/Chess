//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var viewModel = GameViewModel()
    
    let boardWidth = UIScreen.main.bounds.width
    
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
            ZStack {
                BoardView(viewModel: viewModel, tileWidth: tileWidth, boardWidth: boardWidth)
                    .frame(
                        width: boardWidth,
                        height: boardWidth,
                        alignment: .center
                    )
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
