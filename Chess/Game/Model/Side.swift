//
//  Side.swift
//  Chess
//
//  Created by Aidan Lee on 1/15/22.
//

import Foundation

enum Side : String, Codable {
    
    case white = "w"
    case black = "b"
    
    var opponent: Side {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
    var name: String {
        switch self {
        case .white:
            return "white"
        case .black:
            return "black"
        }
    }
}
