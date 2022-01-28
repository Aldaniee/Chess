//
//  CapturedPieceTrayView.swift
//  Chess
//
//  Created by Aidan Lee on 1/28/22.
//

import SwiftUI

struct CapturedPieceTrayView: View {
    let capturedPieces: [(piece: Piece, count: Int)]
    var body: some View {
        HStack {
            ForEach(capturedPieces, id: \.piece.id) { capturedPiece in
                CapturedPiece(piece: capturedPiece.piece, count: capturedPiece.count)
                    .padding(CGFloat(capturedPiece.count))
            }
        }
    }
}
struct CapturedPiece: View {
    let piece: Piece
    let count: Int
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                piece.imageNoShadow
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .leading)
                    .offset(x: CGFloat(index*5), y: 0)
            }
        }
        .padding(CGFloat(count))
    }
}
