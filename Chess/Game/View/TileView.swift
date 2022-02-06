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

    let boardFlipped: Bool

    @Binding var selected: Coordinate?
    
    var body: some View {
        ZStack {
            Group {
                Rectangle()
                    .foregroundColor(tile.color)
                if tile.coordinate == selected {
                    Rectangle()
                        .foregroundColor(.orange)
                        .opacity(0.2)
                }
            }
            .frame(
                width: tileWidth,
                height: tileWidth,
                alignment: .center
            )
            subscripts
        }
    }
    var subscripts: some View {
        ZStack {
            if !boardFlipped && tile.coordinate.rankNum == 1
                || boardFlipped && tile.coordinate.rankNum == 8
            {
                Text(String(tile.coordinate.fileLetter))
                    .frame(
                        maxWidth: tileWidth,
                        maxHeight: tileWidth,
                        alignment: .bottomTrailing
                    )
            }
            if !boardFlipped && tile.coordinate.fileLetter == "a"
                || boardFlipped && tile.coordinate.fileLetter == "h"
            {
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
