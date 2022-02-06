//
//  CapturedPieceTrayView.swift
//  Chess
//
//  Created by Aidan Lee on 1/28/22.
//

import SwiftUI

struct CapturedPieceTrayView: View {
    
    @ObservedObject var viewModel: GameViewModel
    
    let side: Side
    let colors: (primary: Color, secondary: Color)
    let size: CGSize
    
    var capturedPieces: [PieceCounter] {
        side == .white
        ? viewModel.whiteCapturedPieces
        : viewModel.blackCapturedPieces
    }
    var pointsUp: Int {
        viewModel.getMaterialBalance(side)
    }
    
    var body: some View {
        HStack {
            ForEach(capturedPieces, id: \.piece.id) { capturedPiece in
                CapturedPiece(piece: capturedPiece.piece, count: capturedPiece.count)
                    .padding(CGFloat(capturedPiece.count))
            }
            if pointsUp != 0 {
                Text("+\(pointsUp)")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(colors.primary)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .leading)
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
        .padding(.trailing, CGFloat(count))
    }
}
