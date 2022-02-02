//
//  BoardView.swift
//  Chess
//
//  Created by Aidan Lee on 1/28/22.
//

import SwiftUI

struct BoardView: View {
    
    @Environment(\.colorScheme) var colorScheme // Phone in light/dark mode
    
    @ObservedObject var viewModel: GameViewModel
    
    var tileWidth: CGFloat

    var body: some View {
        ZStack {
            border
            tiles
        }
    }
    var tiles: some View {
        Group {
            let columns = Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: 8)
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.boardArray) { tile in
                    TileView(tile: tile)
                        .aspectRatio(contentMode: .fill)
                }
            }
        }
    }
    var border: some View {
        Rectangle().stroke(self.colorScheme == .light ? .black : .white, lineWidth: 5)
    }
}
