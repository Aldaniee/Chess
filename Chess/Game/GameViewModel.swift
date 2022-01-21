//
//  GameViewModel.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation

class GameViewModel: ObservableObject {
    
    init(_ board: Board = Board()) {
        self.board = board
        newGame(board: board)
    }
    
    @Published private (set) var board : Board
    
    private (set) var winner : String?
    
    var whiteCapturedPieces = [Piece]()
    var blackCapturedPieces = [Piece]()

    struct FullMove {
        var white: Move
        var black: Move?
        
        var display: String {
            "\(white.fullAlgebraicNotation) \(black?.fullAlgebraicNotation ?? "") "
        }
    }
    
    private (set) var pgn = [FullMove]() // portable game notation
    
    var pgnString: String {
        var pgnString = ""
        for index in 0..<pgn.count {
            pgnString.append("\(index+1). ")
            pgnString.append(pgn[index].display)
        }
        return pgnString
    }
    
    var boardArray: Array<Tile> {
        board.asArray()
    }
    
    // MARK: - Intents
    
    func newGame(board: Board = Board()) {
        self.board = board
        winner = nil
        pgn = [FullMove]()
        self.board.setupBoard()
        whiteCapturedPieces = [Piece]()
        blackCapturedPieces = [Piece]()
    }
    
    func move(_ piece: Piece, from start: Coordinate, to end: Coordinate) {
        let moves = legalMoves(from: Tile(start, piece))
        
        if moves.contains(end) {
            var capturedPiece = board.movePiece(from: start, to: end)
            // Determine if the king is castling inorder to move the rook
            if piece.type == .king && piece.hasMoved == false {
                
                // Kingside/short castle
                if start.upFile()?.upFile() == end {
                    if let rookLocation = start.upFile()?.upFile()?.upFile() {
                        _ = board.movePiece(from: rookLocation, to: start.upFile()!)
                    }
                }
                
                // Queenside/long castle
                if start.downFile()?.downFile() == end {
                    if let rookLocation = start.downFile()?.downFile()?.downFile()?.downFile() {
                        _ = board.movePiece(from: rookLocation, to: start.downFile()!)
                    }
                }
                
            }
            
            
            // En Passant Special Case
            // if a pawn moves diagonal and does not land on a pawn it must be capturing a pawn via en passant
            if piece.type == .pawn && capturedPiece == nil && start.isDiagonal(from: end) {
                capturedPiece = board.removePiece(Coordinate(rankIndex: start.rankIndex, fileIndex: end.fileIndex))
            }
            if let capturedPiece = capturedPiece {
                if board.turn == .white {
                    blackCapturedPieces.append(capturedPiece)
                } else {
                    whiteCapturedPieces.append(capturedPiece)
                }
            }
            recordMove(Move(from: start, to: end, with: piece.type, capturing: capturedPiece?.type, withCheck: inCheck(board, board.turn.opponent)))
            nextTurn()
        }
    }
    func getPiece(from coordinate: Coordinate) -> Piece? {
        return board.getPiece(from: coordinate)
    }
    func getTurn() -> Side {
        return board.turn
    }
    
    // MARK: - Private
    
    private func nextTurn() {
        board.turn = board.turn == .white ? .black : .white
        if hasNoMoves(board.turn) {
            if inCheck(board, board.turn) {
                winner = board.turn.opponent.rawValue
            }
            else {
                winner = "draw"
            }
        }
    }
    
    private func hasNoMoves(_ side: Side) -> Bool {
        var result = true
        board.getAllTilesWithPieces(of: side).forEach { tile in
            if !legalMoves(from: tile).isEmpty {
                result = false
                return
            }
        }
        return result
    }
    
    
    private func recordMove(_ move: Move) {
        if board.turn == .white {
            pgn.append(FullMove(white: move, black: nil))
        } else {
            let fullMove = FullMove(white: pgn.last!.white, black: move)
            pgn.removeLast()
            pgn.append(fullMove)
        }
        print(move.fullAlgebraicNotation)
    }
    
    /// Get all legal moves for a piece from a tile that contains that piece
    /// - Parameter tile: Tile that must contain a piece
    /// - Returns: Array of possible moves
    private func legalMoves(from tile: Tile) -> [Coordinate] {
        if let piece = tile.piece {
            var moves = tile.piece!.allPossibleMoves(from: tile.coordinate, board)
            
            // Add castling moves
            if piece.type == .king
                && piece.hasMoved == false
                && !inCheck(board, board.turn) {
                // king side
                if let newRookCords = tile.coordinate.upFile(),
                   board.isEmpty(newRookCords),
                   !doesMoveIntoCheck(from: tile.coordinate, to: newRookCords),
                   let newKingCords = newRookCords.upFile(),
                   board.isEmpty(newKingCords),
                   let rookCords = newKingCords.upFile(),
                   let piece = board.getPiece(from: rookCords),
                   piece.type == .rook,
                   piece.hasMoved == false
                {
                    moves.append(newKingCords)
                }
                // queen side
                if let newRookCords = tile.coordinate.downFile(),
                   board.isEmpty(newRookCords),
                   !doesMoveIntoCheck(from: tile.coordinate, to: newRookCords),
                   let newKingCords = newRookCords.downFile(),
                   board.isEmpty(newKingCords),
                   let empty = newKingCords.downFile(),
                   board.isEmpty(empty),
                   let rookCords = empty.downFile(),
                   let piece = board.getPiece(from: rookCords),
                   piece.type == .rook,
                   piece.hasMoved == false
                {
                    moves.append(newKingCords)
                }
            }
            
            
            // Remove any moves that move into check
            for move in moves {
                if doesMoveIntoCheck(from: tile.coordinate, to: move) {
                    moves.removeAll(where: { $0 == move })
                }
            }
            return moves
        }
        return [Coordinate]()
    }
    
    private func doesMoveIntoCheck(from start: Coordinate, to end: Coordinate) -> Bool {
        var newState = board.copy()
        _ = newState.movePiece(from: start, to: end)
        return inCheck(newState, board.turn)
    }
    
    /// Checks if the side whose turn it is is in check
    /// - Parameters:
    ///   - state: Board state to check
    ///   - turn: Side whose turn it is
    /// - Returns: if the side whose turn it is is in check
    private func inCheck(_ state: Board, _ turn: Side) -> Bool {
        // define sides
        let kingSide = turn
        let attackingSide = kingSide.opponent
        
        guard let kingTile = state.getKingTile(kingSide) else { print("ERROR: No king on board"); return false }

        let attackingTiles = state.getAllTilesWithPieces(of: attackingSide)
        for tile in attackingTiles {
            guard let piece = tile.piece else { print("ERROR: Tile needs piece"); return false}
            let moves = piece.threatsCreated(from: tile.coordinate, state)
            for move in moves {
                if move == kingTile.coordinate {
                    return true
                }
            }
        }
        return false
    }
}
