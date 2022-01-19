//
//  Side.swift
//  Chess
//
//  Created by Aidan Lee on 1/15/22.
//

import Foundation

enum Side : String, Codable {
    
    case white = "white"
    case black = "black"
    
    var opponent: Side {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
    var abbreviation: String {
        switch self {
        case .white:
        return "w"
        case .black:
        return "b"
        }
    }
}
