//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Kislov Vadim on 07.01.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testYesButton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterImageData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["buttonYes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterImageData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterImageData, secondPosterImageData)
    }
    
    func testEndOfRound() throws {
        sleep(3)
        
        for _ in 1...10 {
            app.buttons["buttonYes"].tap()
            
            sleep(3)
        }
        
        let alert = app.alerts["resultAlert"]
        
        XCTAssert(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
}
