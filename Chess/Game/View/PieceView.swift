//
//  PieceView.swift
//  Chess
//
//  Created by Aidan Lee on 1/13/22.
//

import SwiftUI

struct PieceView: View {
    
    let tile: Tile
    @ObservedObject var viewModel: GameViewModel
    @State private var dragAmount = CGSize.zero
    @State private var scaleAmount: CGFloat = 1.0
    
    var dropToSelectTile: (Coordinate?) -> Void
    @Binding var selectedTile: Coordinate?
    @Binding var highlightedTile: Coordinate?

    let boardTop: CGFloat
    let tileWidth: CGFloat
    
    var dragGesture: some Gesture {
        let scaleFactor = CGFloat(3)
        let startCoordinate = tile.coordinate
        let piece = tile.piece
        let dragGesture = DragGesture(coordinateSpace: .global)
            .onChanged { dragValue in
                if viewModel.turn == piece?.side {
                    scaleAmount = scaleFactor
                    selectedTile = startCoordinate
                    self.dragAmount = CGSize(width: dragValue.translation.width/scaleFactor, height: dragValue.translation.height/scaleFactor)
                    let rank = 7 - Int((dragValue.location.y - boardTop) / tileWidth)
                    let file = Int((dragValue.location.x) / tileWidth)
                    highlightedTile = Coordinate(rank, file)
                }
            }
            .onEnded { dragValue in
                self.dragAmount = .zero
                scaleAmount = 1.0
                if let highlightedTile = highlightedTile {
                    dropToSelectTile(highlightedTile)
                }
                highlightedTile = nil
            }
        return dragGesture
    }
    var body: some View {
        Group {
            if let piece = tile.piece {
                piece.image
                    .resizable()
                    .scaledToFit()
                    .offset(dragAmount)
                    .scaleEffect(scaleAmount, anchor: .center)
                    .animation(.easeInOut(duration: 0.05), value: scaleAmount)
                    .gesture(dragGesture)
            } else {
                Spacer()
            }
        }
        .padding(5)
        .frame(
            width: tileWidth,
            height: tileWidth,
            alignment: .center
        )
    }
}
