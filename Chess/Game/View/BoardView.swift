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
                TileView(tile: tile, tileWidth: tileWidth, selected: $selected)
                    .onTapGesture {
                        selectTile(at: tile.coordinate)
                    }
            }
        }
    }
    var pieces: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.boardArray, id: \.coordinate.notation) { tile in
                PieceView(tile: tile, tileWidth: tileWidth)
                    .onTapGesture {
                        selectTile(at: tile.coordinate)
                    }
            }
        }
    }
    var border: some View {
        Rectangle()
            .stroke(colorScheme == .light ? .black : .white, lineWidth: 5)
    }
    // MARK: - Private Functions
    private func selectTile(at newSelection: Coordinate) {
        let madeSameSelection = selected == newSelection
        
        if selected == nil {
            selected = newSelection
        } else if madeSameSelection {
            selected = nil
        } else {
            let madeMove = viewModel.makeMoveIfLegal(from: selected!, to: newSelection)
            self.selected = madeMove ? nil : newSelection
        }
    }
}
