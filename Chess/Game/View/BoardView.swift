//
//  BoardView.swift
//  Chess
//
//  Created by Aidan Lee on 1/28/22.
//

import SwiftUI

struct BoardView: View {
    @Environment(\.colorScheme) var colorScheme

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
            .stroke(self.colorScheme == .light ? .black : .white, lineWidth: 5)
    }
    
    // MARK: - Private Functions
    private func selectTile(at newSelection: Coordinate) {
        let madeSameSelection = selected == newSelection
        let madeSelection = selected != nil
        let madeMove = madeSelection && !viewModel.selectedOwnPiece(newSelection) && makeMoveIfValid(from: selected, to: newSelection)

        selected = madeSameSelection || madeMove ? nil : newSelection
    }
    private func makeMoveIfValid(from oldSelection: Coordinate?, to newSelection: Coordinate?) -> Bool {
        if let start = oldSelection,
           let end = newSelection,
           let movingPiece = viewModel.getPiece(from: start),
           movingPiece.side == viewModel.turn
        {
            viewModel.move(from: start, to: end)
            return true
        }
        return false
    }
}
