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
    
    var selectTile: (Coordinate) -> Void
    @Binding var selected: Coordinate?
    @Binding var highlighted: Coordinate?

    let boardTop: CGFloat
    let tileWidth: CGFloat
    
    let scaleFactor: CGFloat = 3
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { dragValue in
                if viewModel.turn == tile.piece?.side {
                    scaleAmount = scaleFactor
                    selected = tile.coordinate
                    dragAmount = CGSize(width: dragValue.translation.width/scaleFactor, height: dragValue.translation.height/scaleFactor)
                    
                    let rank = viewModel.boardFlipped
                    ? Int((dragValue.location.y - boardTop) / tileWidth)
                    : 7 - Int((dragValue.location.y - boardTop) / tileWidth)
                    
                    let file = viewModel.boardFlipped
                    ? 7 - Int((dragValue.location.x) / tileWidth)
                    : Int((dragValue.location.x) / tileWidth)
                    
                    highlighted = Coordinate(rank, file)
                }
            }
            .onEnded { dragValue in
                self.dragAmount = .zero
                scaleAmount = 1.0
                if let highlighted = highlighted {
                    selectTile(highlighted)
                }
                highlighted = nil
            }
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
                    .gesture(drag)
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
