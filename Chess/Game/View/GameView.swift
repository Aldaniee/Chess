//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {

    @ObservedObject var viewModel = GameViewModel()
    
    let boardWidth = UIScreen.main.bounds.width
    
    var tileWidth: CGFloat {
        boardWidth / CGFloat(8)
    }
    
    var body: some View {
        VStack {
            Spacer()
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
