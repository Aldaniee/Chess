//
//  UnitTests.swift
//  UnitTests
//
//  Created by Aidan Lee on 1/19/22.
//

import XCTest
@testable import Chess

class UnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodeGameFromMockJson() {
        var game: Game?
        if let path = Bundle.main.path(forResource: "MockJSONBoard", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                game = try JSONDecoder().decode(Game.self, from: data)
            }
            catch {
                print(error)
            }
            XCTAssertNotNil(game)
        }
        else {
            XCTFail("Error in MockJSON Path")
        }
    }
    func testEncodeMockJSONFromBoard() {
        var result: Data?
        do {
            result = try JSONEncoder().encode(Game())
        }
        catch {
            print(error)
        }
        XCTAssertNotNil(result)
    }
    func testEncodeMockJSONFromBoards() {
        var result: Data?
        var boards = [Game]()
        boards.append(Game())
        do {
            result = try JSONEncoder().encode(boards)
        }
        catch {
            print(error)
        }
        XCTAssertNotNil(result)
    }
}
