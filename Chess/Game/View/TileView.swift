//
//  TileView.swift
//  Chess
//
//  Created by Aidan Lee on 1/13/22.
//

import SwiftUI

struct TileView: View {
    
    let tile: Tile
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .foregroundColor(tile.display.color)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.width,
                        alignment: .center
                    )
                subscripts
            }
        }
    }
    var subscripts: some View {
        GeometryReader { geometry in
            Group {
                if tile.coordinate.rankNum == 1 {
                    Text(String(tile.coordinate.fileLetter))
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                }
                if tile.coordinate.fileLetter == "a" {
                    Text(String(tile.coordinate.rankNum))
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                }
            }
            .foregroundColor(tile.display.inverseColor)
            .opacity(0.8)
            .font(.system(size: 14, weight: .heavy, design: .default))
            .padding(3)
        }
    }

}
