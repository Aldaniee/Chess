//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var game = Game()
    @State var highlightedTile: Coordinate? = nil
    let boardWidth = UIScreen.screenWidth
    let tileWidth = UIScreen.screenWidth / CGFloat(Board.Constants.dimensions)

    var body: some View {
        VStack {
            Spacer()
            Spacer(minLength: 100)
            Button("New Game") {
                game.newGame()
            }
            ZStack {
                board
                dragIndicationCircle
                winnerCard
            }
            .frame(
                width: boardWidth,
                height: boardWidth,
                alignment: .center
            )
            ScrollView {
                Text(game.pgnString)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(colorScheme == .light ? .black : .white)
                    .padding()
            }.frame(width: boardWidth, height: 100, alignment: .topLeading)
            Spacer()

        }
    }
    var dragIndicationCircle: some View {
        Group {
            if let highlightedTile = highlightedTile {
                let fileIndex = highlightedTile.fileIndex
                let rankIndex = highlightedTile.rankIndex
                let circleOffset = CGSize(
                    width: tileWidth/CGFloat(2) - boardWidth/CGFloat(2) + CGFloat(fileIndex) * tileWidth,
                    height: -tileWidth/CGFloat(2) + boardWidth/CGFloat(2) - CGFloat(rankIndex) * tileWidth
                )
                let circleSize = tileWidth*3
                Circle()
                .foregroundColor(.gray)
                .opacity(0.4)
                .frame(width: circleSize, height: circleSize, alignment: .center)
                .offset(circleOffset)
            }
        }
    }
    var winnerCard: some View {
        ZStack {
            if let winner = game.winner {
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
    var board: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(colorScheme == .light ? .black : .white, lineWidth: 5)
                VStack {
                    let columns =
                    Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: Board.Constants.dimensions)
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
                                Piece(tile: tile, game: game, highlightedTile: $highlightedTile, boardTop: geometry.frame(in: .global).minY, tileWidth: tileWidth)
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
        @Binding var highlightedTile: Coordinate?

        let boardTop: CGFloat
        let tileWidth: CGFloat
        
        let scaleFactor: CGFloat = 3
        
        var body: some View {
            let startCoord = tile.coordinate
            let piece = tile.piece
            let dragGesture = DragGesture(coordinateSpace: .global)
                .onChanged { dragValue in
                    if game.turn == piece?.side {
                        scaleAmount = scaleFactor
                        self.dragAmount = CGSize(width: dragValue.translation.width/scaleFactor, height: dragValue.translation.height/scaleFactor)
                        game.selectTile(startCoord)
                        let rank = Board.Constants.maxIndex - Int((dragValue.location.y - boardTop) / tileWidth)
                        let file = Int((dragValue.location.x) / tileWidth)
                        highlightedTile = Coordinate(rankIndex: rank, fileIndex: file)
                    }
                }
                .onEnded { dragValue in
                    self.dragAmount = .zero
                    scaleAmount = 1.0
                    if let highlightedTile = highlightedTile {
                        game.selectTile(highlightedTile)
                    }
                    highlightedTile = nil
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
                        .animation(.easeInOut(duration: 0.05), value: scaleAmount)
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
                            .foregroundColor(tile.display.color)
                        if tile.coordinate == selectedTile {
                            Rectangle()
                                .foregroundColor(.orange)
                                .opacity(0.2)
                        }
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.width,
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
                .foregroundColor(tile.display.inverseColor)
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
