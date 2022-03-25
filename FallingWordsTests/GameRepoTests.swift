//
//  GameRepoTests.swift
//  FallingWordsTests
//
//  Created by Hossein Asadi on 3/25/22.
//

import XCTest
@testable import FallingWords

class GameRepoTests: XCTestCase {
    var sut: LocalWordsRepo!

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }

    func testFetchWords_returnSuccess() throws {
        let expectation = XCTestExpectation(description: "Get the result")
        sut = LocalWordsRepo()
        sut.fetchWords(completion: { result in
            switch result {
            case .success(let words):
                XCTAssertEqual(words.count, 297)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWords_returnFailure() throws {
        let expectation = XCTestExpectation(description: "Get the result")
        sut = LocalWordsRepo(bundle: Bundle(for: type(of: self)))
        sut.fetchWords(completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                break
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

}
