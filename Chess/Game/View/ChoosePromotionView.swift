//
//  ChoosePromotionView.swift
//  Chess
//
//  Created by Aidan Lee on 1/28/22.
//

import SwiftUI

struct ChoosePromotionView: View {
    @Binding var promotionSquare: Coordinate?
    @Binding var promotionStart: Coordinate?
    let moveAndPromote: (Coordinate, Coordinate, Piece) -> Void
    let tileWidth: CGFloat
    var side: Side? {
        promotionSquare?.rankNum == 8 ? .white : .black
    }
    var pieceSize: CGFloat {
        CGFloat(tileWidth * 0.9)
    }
    var body: some View {
        ZStack {
            if promotionSquare != nil && promotionStart != nil && side != nil {
                RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0))
                    .frame(
                        width: tileWidth*2.25,
                        height: tileWidth*2.25,
                        alignment: .center
                    )
                    .foregroundColor(.white)
                    .opacity(0.95)
                VStack {
                    HStack {
                        Button {
                            moveAndPromote(promotionStart!, promotionSquare!, Queen(side!))
                            promotionSquare = nil
                        } label: {
                            Queen(side!).imageNoShadow
                                .resizable()
                        }
                        .frame(width: pieceSize, height: pieceSize, alignment: .center)
                        Button {
                            moveAndPromote(promotionStart!, promotionSquare!, Bishop(side!))
                            promotionSquare = nil
                        } label: {
                            Bishop(side!).imageNoShadow
                                .resizable()
                        }
                        .frame(width: pieceSize, height: pieceSize, alignment: .center)
                    }
                    HStack {
                        Button {
                            moveAndPromote(promotionStart!, promotionSquare!, Rook(side!))
                            promotionSquare = nil
                        } label: {
                            Rook(side!).imageNoShadow
                                .resizable()
                        }
                        .frame(width: pieceSize, height: pieceSize, alignment: .center)
                        Button {
                            moveAndPromote(promotionStart!, promotionSquare!, Knight(side!))
                            promotionSquare = nil
                        } label: {
                            Knight(side!).imageNoShadow
                                .resizable()
                        }
                        .frame(width: pieceSize, height: pieceSize, alignment: .center)
                    }
                }
            }
        }
    }
}
