//
//  GameStatus.swift
//  Chess
//
//  Created by Aidan Lee on 1/31/22.
//

import Foundation

enum GameStatus {
    case playing
    case checkmating
    case flagging
    case resigning
    case drawingByPosition
    case drawingByRepetition
    case drawingByFiftyMoveRule
    case drawingByAgreement
    
    var display: String {
        switch self {
        case .playing:
            return "In Progress"
        case .checkmating:
            return "by Checkmate"
        case .flagging:
            return "by Flagging"
        case .resigning:
            return "by Resignation"
        case .drawingByPosition:
            return "Draw"
        case .drawingByRepetition:
            return "Draw by Repetition"
        case .drawingByFiftyMoveRule:
            return "Draw by Fifty Move Rule"
        case .drawingByAgreement:
            return "Draw by Agreement"
        }
    }
}
