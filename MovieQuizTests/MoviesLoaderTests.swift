//
//  MoviesLoaderTests.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 05.01.2026.
//

import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let moviesLoader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        // Then
        moviesLoader.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let moviesLoader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        // Then
        moviesLoader.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Unexpected failure")
            case .failure(let error):
                XCTAssertNotNil(error)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
