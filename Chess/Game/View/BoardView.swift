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

    
    private func clickToSelectTile(at newSelection: Coordinate) async {
        if selectedTile != nil && selectedTile == newSelection {
            selectedTile = nil
        }
        else if selectedTile != nil && !viewModel.selectedOwnPiece(newSelection) {
            await makeSecondSelection(at: newSelection)
        } else {
            selectedTile = newSelection
        }
    }
    
    private func makeSecondSelection(at newSelection: Coordinate?) async {
        if await makeMoveIfValid(from: selectedTile, to: newSelection) {
            selectedTile = nil
        }
    }
    private func makeMoveIfValid(from oldSelection: Coordinate?, to newSelection: Coordinate?) async -> Bool {
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
                            await NetworkManager.shared.updateGame(viewModel.game)
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
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle().stroke(self.colorScheme == .light ? .black : .white, lineWidth: 5)
                let columns =
                Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: 8)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(viewModel.boardArray) { tile in
                        TileView(tile: tile, selectedTile: selectedTile)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                Task {
                                    await clickToSelectTile(at: tile.coordinate)
                                }
                            }
                    }
                }
                Spacer(minLength: 0)
                dragIndicationCircle
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(viewModel.boardArray) { tile in
                        PieceView(tile: tile, viewModel: viewModel, dropToSelectTile: makeSecondSelection(at:), selectedTile: $selectedTile, highlightedTile: $highlightedTile, boardTop: geometry.frame(in: .global).minY, tileWidth: tileWidth)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                Task {
                                    await clickToSelectTile(at: tile.coordinate)
                                }
                            }
                        .zIndex(selectedTile == tile.coordinate ? 1000 : 0)
                    }
                }
                ChoosePromotionView(promotionSquare: $promotionSquare, promotionStart: $promotionStart, moveAndPromote: viewModel.move(from:to:promotesTo:), tileWidth: tileWidth)
            }
        }
    }
}
