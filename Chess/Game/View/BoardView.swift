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
    @State var highlightedTile: Coordinate? = nil
    @State var selectedTile: Coordinate? = nil
    @State var promotionSquare: Coordinate? = nil
    @State var promotionStart: Coordinate? = nil
    
    let boardWidth: CGFloat
    
    var tileWidth: CGFloat {
        boardWidth / CGFloat(8)
    }
    var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: 8)
    }

    init(viewModel: GameViewModel, boardWidth: CGFloat) {
        self.viewModel = viewModel
        self.boardWidth = boardWidth
    }
    
    private func clickToSelectTile(at newSelection: Coordinate) {
        if selectedTile != nil && selectedTile == newSelection {
            selectedTile = nil
        }
        else if selectedTile != nil && !viewModel.selectedOwnPiece(newSelection) {
            makeSecondSelection(at: newSelection)
        } else {
            selectedTile = newSelection
        }
    }
    
    private func makeSecondSelection(at newSelection: Coordinate?) {
        if makeMoveIfValid(from: selectedTile, to: newSelection) {
            selectedTile = nil
        }
    }
    private func makeMoveIfValid(from oldSelection: Coordinate?, to newSelection: Coordinate?) -> Bool {
        if let start = oldSelection {
            if let end = newSelection {
                if let movingPiece = viewModel.getPiece(from: start) {
                    if movingPiece.side == viewModel.turn {
                        if movingPiece.type == .pawn
                            && (end.rankNum == 8 || end.rankNum == 1)
                            && viewModel.isValidMove(movingPiece, from: start, to: end)
                        {
                            promotionStart = start
                            promotionSquare = end
                        }
                        else {
                            viewModel.move(from: start, to: end)
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    var dragIndicationCircle: some View {
        Group {
            if let highlightedTile = highlightedTile {
                let fileIndex = highlightedTile.fileIndex
                let rankIndex = highlightedTile.rankIndex
                let boardCenter = boardWidth/CGFloat(2)
                let tileCenter = tileWidth/CGFloat(2)
                let circleOffset = CGSize(
                    width: tileCenter - boardCenter + CGFloat(fileIndex) * tileWidth,
                    height: -tileCenter + boardCenter - CGFloat(rankIndex) * tileWidth
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
    var body: some View {
        ZStack {
            border
            tiles
            Spacer(minLength: 0)
            dragIndicationCircle
            pieces
            ChoosePromotionView(promotionSquare: $promotionSquare, promotionStart: $promotionStart, moveAndPromote: viewModel.move(from:to:promotesTo:), tileWidth: tileWidth)
        }
    }
    var tiles: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.boardArray) { tile in
                TileView(tile: tile, selectedTile: selectedTile)
                    .aspectRatio(contentMode: .fill)
                    .onTapGesture {
                        clickToSelectTile(at: tile.coordinate)
                    }
            }
        }
    }
    var pieces: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.boardArray) { tile in
                    PieceView(tile: tile, viewModel: viewModel, dropToSelectTile: makeSecondSelection(at:), selectedTile: $selectedTile, highlightedTile: $highlightedTile, boardTop: geometry.frame(in: .global).minY, tileWidth: tileWidth)
                        .aspectRatio(contentMode: .fill)
                        .onTapGesture {
                            clickToSelectTile(at: tile.coordinate)
                        }
                        .zIndex(selectedTile == tile.coordinate ? 1000 : 0)
                }
            }
        }
    }
    var border: some View {
        Rectangle()
            .stroke(self.colorScheme == .light ? .black : .white, lineWidth: 5)
    }
}
