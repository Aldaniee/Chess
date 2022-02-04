//
//  Piece.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

protocol Piece {
    var type: PieceType { get }
    var side: Side { get }
}
extension Piece {
    var image: Image {
        Image("\(side.rawValue)_\(type.rawValue)_shadow")
    }
}

enum PieceType : String {
    case pawn, king, queen, rook, bishop, knight
}
