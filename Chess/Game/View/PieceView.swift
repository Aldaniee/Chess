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
    var body: some View {
        Group {
            if let piece = tile.piece {
                piece.image
                    .resizable()
                    .scaledToFit()
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
