//
//  CheckTests.swift
//  Chess
//
//  Created by Aidan Lee on 2/10/22.
//

import XCTest
@testable import Chess

class CheckTests: XCTestCase {

    func testBlackCheckmateWhite() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. f4 e5 2. g4 Qh4"
        _ = gameViewModel.makeMultipleMovesIfValid(pgnString)
        XCTAssertTrue(gameViewModel.isCheckmate())
    }

}
