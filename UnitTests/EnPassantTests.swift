//
//  EnPassantTests.swift
//  Chess
//
//  Created by Aidan Lee on 2/10/22.
//

import XCTest
@testable import Chess

class EnPassantTests: XCTestCase {
    
    // MARK: False negatives
    
    // MARK: White En Passants Black Pawn
    func testEnPassantTargetSquareSetByBlackPawn() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e4 d5 2. e5 f5"
        _ = gameViewModel.makeMultipleMovesIfValid(pgnString)
        XCTAssertTrue(gameViewModel.enPassantTarget == Coordinate(notation: "f5"))
    }
    func testEnPassantMoveWhitePawn() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e4 d5 2. e5 f5 3. exf6"
        XCTAssertTrue(gameViewModel.makeMultipleMovesIfValid(pgnString))
    }
    func testEnPassantCapturesBlackPawn() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e4 d5 2. e5 f5 3. exf6"
        _ = gameViewModel.makeMultipleMovesIfValid(pgnString)
        XCTAssertTrue(gameViewModel.getPiece(Coordinate(notation: "f5")) == nil)
    }
    
    // MARK: Black En Passants White Pawn
    func testEnPassantTargetSquareSetByWhitePawn() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e3 d5 2. h3 d4 3. c4"
        _ = gameViewModel.makeMultipleMovesIfValid(pgnString)
        XCTAssertTrue(gameViewModel.enPassantTarget == Coordinate(notation: "c4"))
    }
    func testEnPassantMoveBlackPawn() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e3 d5 2. h3 d4 3. c4 dxc3"
        XCTAssertTrue(gameViewModel.makeMultipleMovesIfValid(pgnString))
    }
    func testEnPassantCapturesWhitePawn() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e3 d5 2. h3 d4 3. c4 dxc3"
        _ = gameViewModel.makeMultipleMovesIfValid(pgnString)
        XCTAssertTrue(gameViewModel.getPiece(Coordinate(notation: "c4")) == nil)
    }
    
    // MARK: False positives
    
    // En Passant doesn't work on second turn
    func testLateEnPassant() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e4 d5 2. e5 f5 3. exd6"
        XCTAssertFalse(gameViewModel.makeMultipleMovesIfValid(pgnString))
    }
    
    // En Passant doesn't work on wrong rank turn
    func testMisplacedEnPassant() {
        let gameViewModel = GameViewModel()
        let pgnString = "1. e4 d5 2. e5 dxe4"
        XCTAssertFalse(gameViewModel.makeMultipleMovesIfValid(pgnString))
    }
}
