//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game = Game()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Button("New Game") {
                    game.newGame()
                }
                ZStack {
                    Rectangle()
                        .stroke(Color.black, lineWidth: 3)
                    board
                    if let winner = game.winner {
                        WinnerCard(width: geometry.minWidthHeight(), winner: winner)
                            .frame(
                                width: geometry.minWidthHeight() - 140,
                                height: geometry.minWidthHeight() - 140,
                                alignment: .center
                            )
                    }
                }
                .frame(
                    width: geometry.minWidthHeight(),
                    height: geometry.minWidthHeight(),
                    alignment: .center
                )
                Spacer()
            }
        }
    }
    
    var board: some View {
        GeometryReader { geometry in
            VStack {
                let width = geometry.size.width / CGFloat(Board.Constants.dimensions)
                let columns =
                Array(repeating: GridItem(.fixed(width), spacing: 0), count: Board.Constants.dimensions)
                let top = geometry.frame(in: .global).minY
                ZStack {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(game.boardArray) { tile in
                            TileView(tile: tile, selectedTile: game.selectedTile)
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    game.selectTile(tile.coordinate)
                                }
                        }
                    }
                    Spacer(minLength: 0)
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(game.boardArray) { tile in
                            Piece(tile: tile, game: game, boardTop: top, tileWidth: width)
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    game.selectTile(tile.coordinate)
                                }
                                .zIndex(game.selectedTile == tile.coordinate ? 1 : 0)

                        }
                    }
                }
            }
        }
    }
    
    struct WinnerCard: View {
        let width: CGFloat
        let winner: String
        
        var body: some View {
            ZStack {
                let shape = RoundedRectangle(cornerSize: CGSize(width: 60, height: 60))
                shape.fill().foregroundColor(.white).opacity(0.90)
                shape.stroke(Color.black, lineWidth: 3)
                Group {
                    if winner == "draw" {
                        Text("Draw!")
                    }
                    else {
                        Text("\(winner) Won!")
                    }
                }
                .font(.system(size: CGFloat(30)))
                .foregroundColor(.black)
            }
        }
    }
    
    struct Piece: View {
        
        let tile: Tile
        @ObservedObject var game: Game
        @State private var dragAmount = CGSize.zero
        @State private var scaleAmount: CGFloat = 1.0
        
        let boardTop: CGFloat
        let tileWidth: CGFloat
        
        let scaleFactor: CGFloat = 2
        
        var body: some View {
            let startCoord = tile.coordinate
            let piece = tile.piece
            let dragGesture = DragGesture(coordinateSpace: .global)
                .onChanged { dragValue in
                    if game.turn == piece?.side {
                        scaleAmount = scaleFactor
                        self.dragAmount = CGSize(width: dragValue.translation.width/scaleFactor, height: dragValue.translation.height/scaleFactor)
                        game.selectTile(startCoord)
                    }
                }
                .onEnded { dragValue in
                    self.dragAmount = .zero
                    scaleAmount = 1.0
                    let rank = Board.Constants.maxIndex - Int((dragValue.location.y - boardTop) / tileWidth)
                    let file = Int((dragValue.location.x) / tileWidth)
                    game.selectTile(Coordinate(rankIndex: rank, fileIndex: file))
                    game.deselect()
                }
            
            GeometryReader { geometry in
                if piece != nil {
                    piece!.image
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: (geometry.size.width-10),
                            height: geometry.size.width-10,
                            alignment: .center
                        )
                        .padding(5)
                        .offset(dragAmount)
                        .scaleEffect(scaleAmount, anchor: .center)
                        .animation(.easeInOut(duration: 0.1), value: scaleAmount)
                        .gesture(dragGesture)
                }
            }
        }
    }
    
    struct TileView: View {
        
        let tile: Tile
        var selectedTile: Coordinate?

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Group {
                        Rectangle()
                            .foregroundColor(tile.color)
                        if tile.coordinate == selectedTile {
                        Rectangle()
                            .foregroundColor(.orange)
                            .opacity(0.2)
                        }
                    }
                    .frame(
                        width: geometry.minWidthHeight(),
                        height: geometry.minWidthHeight(),
                        alignment: .center
                    )
                    subscripts
                }
            }
        }
        var subscripts: some View {
            GeometryReader { geometry in
                Group {
                    if tile.coordinate.rankNum == 1 {
                        Text(String(tile.coordinate.fileLetter))
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                    }
                    if tile.coordinate.fileLetter == "a" {
                        Text(String(tile.coordinate.rankNum))
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                    }
                }
                .foregroundColor(tile.color)
                .colorInvert()
                .opacity(0.8)
                .font(.system(size: 14, weight: .heavy, design: .default))
                .padding(3)
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
