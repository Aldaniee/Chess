//
//  PieceView.swift
//  Chess
//
//  Created by Aidan Lee on 1/13/22.
//

import SwiftUI

struct PieceView: View {
    
    let tile: Tile
    @ObservedObject var game: GameViewModel
    @State private var dragAmount = CGSize.zero
    @State private var scaleAmount: CGFloat = 1.0
    
    var dropToSelectTile: (Coordinate?) async -> Void
    @Binding var selectedTile: Coordinate?
    @Binding var highlightedTile: Coordinate?

    let boardTop: CGFloat
    let tileWidth: CGFloat
    
    let scaleFactor: CGFloat = 3
    
    var body: some View {
        let startCoordinate = tile.coordinate
        let piece = tile.piece
        let dragGesture = DragGesture(coordinateSpace: .global)
            .onChanged { dragValue in
                if game.getTurn() == piece?.side {
                    scaleAmount = scaleFactor
                    selectedTile = startCoordinate
                    self.dragAmount = CGSize(width: dragValue.translation.width/scaleFactor, height: dragValue.translation.height/scaleFactor)
                    let rank = Game.Constants.maxIndex - Int((dragValue.location.y - boardTop) / tileWidth)
                    let file = Int((dragValue.location.x) / tileWidth)
                    highlightedTile = Coordinate(rankIndex: rank, fileIndex: file)
                }
            }
            .onEnded { dragValue in
                self.dragAmount = .zero
                scaleAmount = 1.0
                if let highlightedTile = highlightedTile {
                    Task {
                        await dropToSelectTile(highlightedTile)
                    }
                }
                highlightedTile = nil
            }
        
        GeometryReader { geometry in
            if piece != nil {
                piece!.image
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width-10,
                        height: geometry.size.width-10,
                        alignment: .center
                    )
                    .padding(5)
                    .offset(dragAmount)
                    .scaleEffect(scaleAmount, anchor: .center)
                    .animation(.easeInOut(duration: 0.05), value: scaleAmount)
                    .gesture(dragGesture)
            }
        }
    }
}
