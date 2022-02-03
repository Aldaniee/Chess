//
//  TileView.swift
//  Chess
//
//  Created by Aidan Lee on 1/13/22.
//

import SwiftUI

struct TileView: View {
    
    let tile: Tile
    
    let tileWidth: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(tile.color)
                .frame(
                    width: tileWidth,
                    height: tileWidth,
                    alignment: .center
                )
            subscripts
        }
    }
    var subscripts: some View {
        Group {
            if tile.coordinate.rankNum == 1 {
                Text(String(tile.coordinate.fileLetter))
                    .frame(
                        maxWidth: tileWidth,
                        maxHeight: tileWidth,
                        alignment: .bottomTrailing
                    )
            }
            if tile.coordinate.fileLetter == "a" {
                Text(String(tile.coordinate.rankNum))
                    .frame(
                        maxWidth: tileWidth,
                        maxHeight: tileWidth,
                        alignment: .topLeading
                    )
            }
        }
        .foregroundColor(tile.color)
        .colorInvert()
        .opacity(0.8)
        .font(.system(size: 14, weight: .heavy, design: .default))
        .padding(3)
    }
}

