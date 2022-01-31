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
    
    let boardWidth = UIScreen.screenWidth
    let captureTrayHeight = CGFloat(40)
    let pgnDisplayHeight = CGFloat(100)
    let pgnMode = false
    
    var tileWidth: CGFloat {
        boardWidth / CGFloat(8)
    }
    
    var body: some View {
        VStack {
            Spacer()
            if pgnMode {
                Spacer(minLength: pgnDisplayHeight)
            }
            Button {
                viewModel.newGame()
            } label: {
                Text("New Game")
            }
            CapturedPieceTrayView(capturedPieces: viewModel.game.whiteCapturedPieces)
                .frame(width: boardWidth, height: captureTrayHeight, alignment: .leading)
            ZStack {
                BoardView(viewModel: viewModel, boardWidth: boardWidth)
                winnerCard
            }
            .frame(
                width: boardWidth,
                height: boardWidth,
                alignment: .center
            )
            CapturedPieceTrayView(capturedPieces: viewModel.game.blackCapturedPieces)
                .frame(width: boardWidth, height: captureTrayHeight, alignment: .leading)
            if pgnMode {
                ScrollView {
                    Text(viewModel.pgnString)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding()
                }.frame(width: boardWidth, height: pgnDisplayHeight, alignment: .topLeading)
            }
            Spacer()
        }
    }
    
    var winnerCard: some View {
        ZStack {
            let status = viewModel.game.gameStatus
            let turn = viewModel.turn
            if status != .playing {
                let shape = RoundedRectangle(cornerSize: CGSize(width: 50, height: 50))
                shape.fill().foregroundColor(.white).opacity(0.95)
                shape.stroke(Color.black, lineWidth: 3)
                Group {
                    switch status {
                    case .checkmating, .flagging, .resigning:
                        Text("\(turn.name) Won \(status.display)!")
                    default:
                        Text(status.display)
                    }
                }
                .font(.system(size: CGFloat(30)))
                .foregroundColor(.black)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
