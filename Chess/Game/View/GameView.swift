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
    
    let pgnDisplayHeight = CGFloat(100)
    
    var winnerCardWidth: CGFloat {
        boardWidth - 50
    }
    var captureTraySize: CGSize {
        CGSize(width: boardWidth - 30, height: CGFloat(40))
    }
    var body: some View {
        NavigationView {
            VStack {
                CapturedPieceTrayView(
                    viewModel: viewModel,
                    side: viewModel.boardFlipped ? .white : .black,
                    colors: colors,
                    size: captureTraySize
                )
                ZStack {
                    BoardView(viewModel: viewModel, tileWidth: tileWidth, boardWidth: boardWidth)
                    winnerCard
                }
                CapturedPieceTrayView(
                    viewModel: viewModel,
                    side: viewModel.boardFlipped ? .black : .white,
                    colors: colors,
                    size: captureTraySize
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // <2>
                ToolbarItem(placement: .principal) { // <3>
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
    
    var winnerCard: some View {
        ZStack {
            let status = viewModel.gameStatus
            let turn = viewModel.turn
            if status != .playing {
                let shape = RoundedRectangle(cornerRadius: CGFloat(70))
                shape.fill().foregroundColor(secondaryColor).opacity(0.95)
                shape.stroke(Color.black, lineWidth: 3)
                Group {
                    switch status {
                    case .checkmating, .flagging, .resigning:
                        Text("\(turn.displayName) Won \(status.display)!")
                    default:
                        Text(status.display)
                    }
                }
                .font(.system(size: CGFloat(30)))
                .foregroundColor(primaryColor)
            }
        }
        .frame(
            width: winnerCardWidth,
            height: winnerCardWidth,
            alignment: .center
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
