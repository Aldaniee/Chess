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
    
    var selectTile: (Coordinate) -> Void
    @Binding var selected: Coordinate?
    @Binding var highlighted: Coordinate?

    let boardTop: CGFloat
    
    let tileWidth: CGFloat

    var body: some View {
        piece
            .padding(5)
            .frame(
                width: tileWidth,
                height: tileWidth,
                alignment: .center
            )
    }
    var piece: some View {
        Group {
            if let piece = tile.piece {
                piece.image
                    .resizable()
                    .scaledToFit()
            } else {
                Spacer()
            }
        }
    }
}
