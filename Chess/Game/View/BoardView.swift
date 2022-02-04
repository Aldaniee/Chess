//
//  BoardView.swift
//  Chess
//
//  Created by Aidan Lee on 1/28/22.
//

import SwiftUI

struct BoardView: View {
    @Environment(\.colorScheme) var colorScheme //Phone in light/dark mode

    @ObservedObject var viewModel: GameViewModel
    
    @State var selected: Coordinate? = nil
    
    let tileWidth: CGFloat
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: 8)
    }
    
    var body: some View {
        ZStack {
            border
            tiles
            pieces
        }
    }
    var tiles: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.boardArray, id: \.coordinate.notation) { tile in
                TileView(tile: tile, tileWidth: tileWidth, selected: selected)
            }
        }
    }
    var pieces: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.boardArray, id: \.coordinate.notation) { tile in
                PieceView(tile: tile, tileWidth: tileWidth)
            }
        }
    }
    var border: some View {
        Rectangle()
            .stroke(self.colorScheme == .light ? .black : .white, lineWidth: 5)
    }
}
