//
//  ContentView.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct GameView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: GameViewModel = GameViewModel()
    @State var highlightedTile: Coordinate? = nil
    @State var selectedTile: Coordinate? = nil
    @State var promotionSquare: Coordinate? = nil
    @State var promotionStart: Coordinate? = nil

    private func clickToSelectTile(at newSelection: Coordinate?) async {
        let sameSelection = selectedTile != nil && selectedTile == newSelection
        if sameSelection {
            selectedTile = nil
        }
        else {
            await makeSecondSelection(at: newSelection)
        }
    }
    
    private func makeSecondSelection(at newSelection: Coordinate?) async {
        if await makeMoveIfValid(from: selectedTile, to: newSelection) {
            selectedTile = nil
        }
    }
    
    private func selectTile(at newSelection: Coordinate?) {
        if selectedTile != newSelection {
            selectedTile = newSelection
        }
    }
    
    private func makeMoveIfValid(from oldSelection: Coordinate?, to newSelection: Coordinate?) async -> Bool {
        if let start = oldSelection {
            if let end = newSelection {
                if let movingPiece = viewModel.getPiece(from: start) {
                    if movingPiece.side == viewModel.getTurn() {
                        if movingPiece.type == .pawn
                            && (end.rankNum == 8 || end.rankNum == 1)
                            && viewModel.isValidMove(movingPiece, from: start, to: end)
                        {
                            print("HERE")
                            promotionStart = start
                            promotionSquare = end
                        }
                        else {
                            viewModel.move(movingPiece, from: start, to: end)
                            await NetworkManager.shared.updateGame(viewModel.game)
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    let boardWidth = UIScreen.screenWidth
    let tileWidth = UIScreen.screenWidth / CGFloat(Game.Constants.dimensions)
    let captureTrayHeight = CGFloat(40)
    let pgnMode = false
    var body: some View {
        VStack {
            Spacer()
            if pgnMode {
                Spacer(minLength: 100)
            }
            CapturedPieceTray(capturedPieces: viewModel.whiteCapturedPieces)
                .frame(width: boardWidth, height: captureTrayHeight, alignment: .leading)
            ZStack {
                activeGameView
                winnerCard
                ChoosePromotionView(promotionSquare: $promotionSquare, promotionStart: $promotionStart, promotePawn: viewModel.promotePawn(from:to:into:), tileWidth: tileWidth)
            }
            .frame(
                width: boardWidth,
                height: boardWidth,
                alignment: .center
            )
            CapturedPieceTray(capturedPieces: viewModel.blackCapturedPieces)
                .frame(width: boardWidth, height: captureTrayHeight, alignment: .leading)
            if pgnMode {
                ScrollView {
                    Text(viewModel.pgnString)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding()
                }.frame(width: boardWidth, height: 100, alignment: .topLeading)
            }
            Spacer()
        }
    }
    struct CapturedPieceTray: View {
        let capturedPieces: [(piece: Piece, count: Int)]
        var body: some View {
            HStack {
                ForEach(capturedPieces, id: \.piece.id) { capturedPiece in
                    CapturedPiece(piece: capturedPiece.piece, count: capturedPiece.count)
                        .padding(2)
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
        }
    }
    var dragIndicationCircle: some View {
        Group {
            if let highlightedTile = highlightedTile {
                let fileIndex = highlightedTile.fileIndex
                let rankIndex = highlightedTile.rankIndex
                let circleOffset = CGSize(
                    width: tileWidth/CGFloat(2) - boardWidth/CGFloat(2) + CGFloat(fileIndex) * tileWidth,
                    height: -tileWidth/CGFloat(2) + boardWidth/CGFloat(2) - CGFloat(rankIndex) * tileWidth
                )
                let circleSize = tileWidth*3
                Circle()
                .foregroundColor(.gray)
                .opacity(0.4)
                .frame(width: circleSize, height: circleSize, alignment: .center)
                .offset(circleOffset)
            }
        }
    }
    struct ChoosePromotionView: View {
        @Binding var promotionSquare: Coordinate?
        @Binding var promotionStart: Coordinate?
        let promotePawn: (Coordinate, Coordinate, Piece) -> Void
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
                                promotePawn(promotionStart!, promotionSquare!, Queen(side!))
                                promotionSquare = nil
                            } label: {
                                Queen(side!).imageNoShadow
                                    .resizable()
                            }
                            .frame(width: pieceSize, height: pieceSize, alignment: .center)
                            Button {
                                promotePawn(promotionStart!, promotionSquare!, Bishop(side!))
                                promotionSquare = nil
                            } label: {
                                Bishop(side!).imageNoShadow
                                    .resizable()
                            }
                            .frame(width: pieceSize, height: pieceSize, alignment: .center)
                        }
                        HStack {
                            Button {
                                promotePawn(promotionStart!, promotionSquare!, Rook(side!))
                                promotionSquare = nil
                            } label: {
                                Rook(side!).imageNoShadow
                                    .resizable()
                            }
                            .frame(width: pieceSize, height: pieceSize, alignment: .center)
                            Button {
                                promotePawn(promotionStart!, promotionSquare!, Knight(side!))
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
    
    var winnerCard: some View {
        ZStack {
            if let winner = viewModel.winner {
                let shape = RoundedRectangle(cornerSize: CGSize(width: 60, height: 60))
                shape.fill().foregroundColor(.white).opacity(0.90)
                shape.stroke(Color.black, lineWidth: 3)
                Group {
                    if winner == "draw" {
                        Text("Draw!")
                    }
                    else {
                        Text("\(winner) Won!")
                    }
                }
                .font(.system(size: CGFloat(30)))
                .foregroundColor(.black)
            }
        }
    }
    var activeGameView: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(colorScheme == .light ? .black : .white, lineWidth: 5)
                VStack {
                    let columns =
                    Array(repeating: GridItem(.fixed(tileWidth), spacing: 0), count: Game.Constants.dimensions)
                    ZStack {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(viewModel.boardArray) { tile in
                                Button {
                                    Task {
                                        await clickToSelectTile(at: tile.coordinate)
                                    }
                                } label: {
                                    TileView(tile: tile, selectedTile: selectedTile)
                                        .aspectRatio(contentMode: .fill)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                        dragIndicationCircle
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(viewModel.boardArray) { tile in
                                Button {
                                    Task {
                                        await clickToSelectTile(at: tile.coordinate)
                                    }
                                } label: {
                                    PieceView(tile: tile, game: viewModel, dropToSelectTile: makeSecondSelection(at:), selectedTile: $selectedTile, highlightedTile: $highlightedTile, boardTop: geometry.frame(in: .global).minY, tileWidth: tileWidth)
                                        .aspectRatio(contentMode: .fill)
                                        .zIndex(selectedTile == tile.coordinate ? 1 : 0)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
