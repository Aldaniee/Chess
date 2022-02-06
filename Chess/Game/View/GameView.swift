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
    
    @ObservedObject var viewModel = GameViewModel(Game.promotionTestGame)
    
    let boardWidth = UIScreen.main.bounds.width
    
    var tileWidth: CGFloat {
        boardWidth / CGFloat(8)
    }
    
    let captureTrayHeight = CGFloat(40)
    let pgnDisplayHeight = CGFloat(100)
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                viewModel.newGame()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: CGFloat(10))
                        .stroke(primaryColor, lineWidth: 2)
                        .frame(
                            width: 70,
                            height: 20,
                            alignment: .center
                        )
                    Text("Restart")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(primaryColor)
                }
            }
            CapturedPieceTrayView(
                viewModel: viewModel,
                side: .black,
                colors: colors
            )
                .frame(width: boardWidth-30, height: captureTrayHeight, alignment: .leading)
            ZStack {
                BoardView(viewModel: viewModel, tileWidth: tileWidth, boardWidth: boardWidth)
                    .frame(
                        width: boardWidth,
                        height: boardWidth,
                        alignment: .center
                    )
                winnerCard
                    .frame(
                        width: boardWidth - 50,
                        height: boardWidth - 50,
                        alignment: .center
                    )
            }
            CapturedPieceTrayView(
                viewModel: viewModel,
                side: .white,
                colors: colors
            )
                .frame(width: boardWidth-30, height: captureTrayHeight, alignment: .leading)
            Spacer()
        }
    }
    
    var winnerCard: some View {
        ZStack {
            let status = viewModel.game.gameStatus
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
