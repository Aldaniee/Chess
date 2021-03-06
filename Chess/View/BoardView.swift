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
    
    @State var highlighted: Coordinate? = nil
    @State var selected: Coordinate? = nil
        
    let tileWidth: CGFloat
    
    let boardWidth: CGFloat
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: 8)
    }
    
    var selectedPiece: Piece? {
        selected != nil ? viewModel.getPiece(selected!) : nil
    }
    
    var body: some View {
        ZStack {
            border
            tiles
            dragIndicationCircle
            pieces
            ChoosePromotionView(promotionSquare: $viewModel.promotionEnd, promotionStart: $viewModel.promotionStart, moveAndPromote: viewModel.makeMoveIfLegal(from:to:promotesTo:), tileWidth: tileWidth)
        }
        .frame(
            width: boardWidth,
            height: boardWidth,
            alignment: .center
        )
    }
    var tiles: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.boardArray, id: \.coordinate.notation) { tile in
                TileView(tile: tile, tileWidth: tileWidth, boardFlipped: viewModel.boardFlipped, selected: $selected)
                    .onTapGesture {
                        selectTile(tile.coordinate)
                        viewModel.lastMoveWasDragged = false
                    }
            }
        }
    }
    var pieces: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.boardArray, id: \.coordinate.notation) { tile in
                    PieceView(tile: tile, viewModel: viewModel, selectTile: selectTile, selected: $selected, highlighted: $highlighted, boardTop: geometry.frame(in: .global).minY, tileWidth: tileWidth)
                        .onTapGesture {
                            selectTile(tile.coordinate)
                            viewModel.lastMoveWasDragged = false
                        }
                        .zIndex(selected == tile.coordinate ? 1000 : 0)
                }
            }
        }
    }
    
    var dragIndicationCircle: some View {
        Group {
            if let highlightedTile = highlighted {
                let fileIndex = highlightedTile.fileIndex
                let rankIndex = highlightedTile.rankIndex
                let circleOffset = viewModel.boardFlipped
                ? CGSize(
                    width: -tileWidth/CGFloat(2) + boardWidth/CGFloat(2) - CGFloat(fileIndex) * tileWidth,
                    height: tileWidth/CGFloat(2) - boardWidth/CGFloat(2) + CGFloat(rankIndex) * tileWidth
                )
                : CGSize(
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
    var border: some View {
        Rectangle()
            .stroke(colorScheme == .light ? .black : .white, lineWidth: 5)
    }
    // MARK: - Private Functions
    private func selectTile(_ newSelection: Coordinate) {
        let madeSameSelection = selected == newSelection
        let madeSelection = selected != nil
        let madeMove = madeSelection && viewModel.makeMoveIfLegal(from: selected!, to: newSelection)

        selected = madeSameSelection || madeMove ? nil : newSelection
        
        // click anywhere to remove promotion view
        if !madeMove {
            viewModel.promotionStart = nil
            viewModel.promotionEnd = nil
        }
    }
}
