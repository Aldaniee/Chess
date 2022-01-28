//
//  GameTests.swift
//  UnitTests
//
//  Created by Aidan Lee on 1/28/22.
//

import XCTest
@testable import Chess

class GameTests: XCTestCase {
    
    func testGameIsCheck1() {
        do {
            let game = try FEN.shared.makeGame(from: "rnb1kbnr/pppp1ppp/8/4p3/5P1q/P7/1PPPP1PP/RNBQKBNR/ w KQkq - 1 3")
            XCTAssertTrue(game.isCheck())
        }
        catch {
            XCTFail("Invalid FEN")
        }
    }
    func testGameIsCheck2() {
        do {
            let game = try FEN.shared.makeGame(from: "rnb1kbnr/pppp1ppp/8/4p3/5PPq/P7/1PPPP2P/RNBQKBNR/ w KQkq - 0 4")
            XCTAssertTrue(game.isCheck())
        }
        catch {
            XCTFail("Invalid FEN")
        }
    }
}
