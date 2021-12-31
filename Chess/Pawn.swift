//
//  Pawn.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import SwiftUI

struct Pawn: Piece {
    init(isWhite: Bool) {
        color = isWhite ? .white : .black
    }
    var color: Color
    
    func display() -> String {
        return "P"
    }
    
    func move() {
        print("Pawn Moved")
    }
}
