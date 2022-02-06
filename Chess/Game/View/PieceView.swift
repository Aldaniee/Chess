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
    
    var selectTile: (Coordinate) -> Void
    @Binding var selected: Coordinate?
    @Binding var highlighted: Coordinate?

    let boardTop: CGFloat
    
    let tileWidth: CGFloat
    
    //when dragging scale the piece up for visibility
    let scaleFactor: CGFloat = 3
    // when dragging move piece above thumb so it can be seen
    let thumbOffset: CGFloat = 15
 
    var drag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { dragValue in
                if viewModel.turn == tile.piece?.side {


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
                    .offset(
                        dragAmount == CGSize.zero
                        ? CGSize.zero
                        : CGSize(width: dragAmount.width, height: dragAmount.height - thumbOffset)
                    )
                    .scaleEffect(
                        dragAmount != .zero ? scaleFactor : 1,
                        anchor: .center
                    )
                    .animation(.easeInOut(duration: 0.03), value: scaleFactor)
                    .gesture(drag, including: .all)
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
