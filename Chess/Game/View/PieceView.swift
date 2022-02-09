//
//  PieceView.swift
//  Chess
//
//  Created by Aidan Lee on 1/13/22.
//

import SwiftUI

struct PieceView: View {
    
    let tile: Tile
    
    let tileWidth: CGFloat
    
    var body: some View {
        Group {
            if let piece = tile.piece {
                piece.image
                    .resizable()
                    .scaledToFit()
                    .padding(5)
            } else {
                Spacer()
            }
        }
        .frame(
            width: tileWidth,
            height: tileWidth,
            alignment: .center
        )
    }
}
