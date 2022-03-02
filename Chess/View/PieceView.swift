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
        
    // use for piece dragging on drag move
    @State private var dragAmount = CGSize.zero
    // used for piece sliding on tap move
    @State private var slideAmount = CGSize.zero

    var selectTile: (Coordinate) -> Void
    @Binding var selected: Coordinate?
    @Binding var highlighted: Coordinate?

    let boardTop: CGFloat
    
    let tileWidth: CGFloat
    
    var movedFrom: CGSize? {
        if justMoved {
            if let lastMove = viewModel.lastMove {
                let start = lastMove.start
                let end = lastMove.end
                let rankChange = viewModel.boardFlipped
                ? start.rankIndex - end.rankIndex
                : end.rankIndex - start.rankIndex
                let fileChange = viewModel.boardFlipped
                ? start.fileIndex - end.fileIndex
                : end.fileIndex - start.fileIndex
                return CGSize(
                    width: -CGFloat(fileChange) * tileWidth,
                    height: CGFloat(rankChange) * tileWidth
                )
            }
        }
        return nil
    }
    
    var justMoved: Bool {
        if let piece = tile.piece {
            if let lastMovedPiece = viewModel.lastMove?.piece {
                return lastMovedPiece.id == piece.id
            }
        }
        return false
    }
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
                    viewModel.lastMoveWasDragged = true
                }
                highlighted = nil
            }
    }
    var body: some View {
        piece
            .padding(5)
            .frame(
                width: tileWidth,
                height: tileWidth,
                alignment: .center
            )
            .offset(
                dragAmount != .zero
                ? CGSize(width: dragAmount.width, height: dragAmount.height - thumbOffset)
                : .zero
            )
            .scaleEffect(
                dragAmount != .zero ? scaleFactor : 1,
                anchor: .center
            )
            .animation(.easeInOut(duration: 0.03), value: scaleFactor)
            .gesture(drag)
    }
    var piece: some View {
        Group {
            if let piece = tile.piece {
                piece.image
                    .resizable()
                    .scaledToFit()
                    .offset(slideAmount)
                    .onAppear {
                        if justMoved && !viewModel.lastMoveWasDragged{
                            slideAmount = movedFrom!
                            withAnimation(.easeInOut(duration: 0.15)) {
                                slideAmount = CGSize.zero
                            }
                        }
                    }
            } else {
                Spacer()
            }
        }
    }
}
