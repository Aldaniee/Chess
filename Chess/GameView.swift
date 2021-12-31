//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game = GameViewModel()
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
                LazyVGrid(
                    columns: columns,
                    spacing: 0
                ) {
                    ForEach(game.asArray()) { tile in
                        TileView(tile: tile, selectedTile: game.selectedTile())
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                game.selectTile(tile.coordinate)
                            }
                    }
                }
                Spacer(minLength: 0)
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
                    drawPiece(tile)
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
                    if tile.coordinate.fileLetter == "A" {
                        Text(String(tile.coordinate.rankNum))
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                    }
                }
                .foregroundColor(tile.color)
                .colorInvert()
                .opacity(0.8)
                .font(.system(size: 10, weight: .heavy, design: .default))
                .padding(3)
            }
        }
        @ViewBuilder
        func drawPiece(_ tile: Tile) -> some View {
            if tile.piece != nil {
                ZStack {
                    Text(tile.piece!.display())
                        .foregroundColor(tile.piece?.color)
                        .colorInvert()
                        .font(.system(size: 32, weight: .heavy, design: .default))
                    Text(tile.piece!.display())
                        .foregroundColor(tile.piece?.color)
                        .font(.system(size: 28, weight: .medium, design: .default))
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
