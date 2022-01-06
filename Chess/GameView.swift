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
                ZStack {
                    Rectangle()
                        .stroke(Color.black, lineWidth: 3)
                    board
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
                            Piece(tile: tile, game: game)
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    game.selectTile(tile.coordinate)
                                }
                        }
                    }
                }
            }
        }
    }
    
    struct Piece: View {
        
        let tile: Tile
        @ObservedObject var game: Game
        @State private var dragAmount = CGSize.zero

        var body: some View {
            GeometryReader { geometry in
                if tile.piece != nil {
                    tile.piece!.image
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.height-10,
                            height: geometry.size.width-10,
                            alignment: .center
                        )
                        .padding(5)
                        .offset(dragAmount)
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged {
                                    self.dragAmount = CGSize(width: $0.translation.width, height: $0.translation.height)
                                    game.deselect()
                                }
                                .onEnded { value in
                                    self.dragAmount = .zero
                                    let rankChange = -Int(value.translation.height / geometry.size.height)
                                    let fileChange = Int(value.translation.width / geometry.size.width)
                                    let start = tile.coordinate
                                    game.selectTile(start)
                                    game.selectTile(Coordinate(rankIndex: start.rankIndex + rankChange, fileIndex: start.fileIndex + fileChange))
                                }
                        )
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
