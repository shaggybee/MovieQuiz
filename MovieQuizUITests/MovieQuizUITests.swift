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
        sleep(Constants.delay)
        
        let firstPoster = app.images[Constants.Identifiers.movieImage]
        let firstPosterImageData = firstPoster.screenshot().pngRepresentation
        
        app.buttons[Constants.Identifiers.buttonYes].tap()
        
        sleep(Constants.delay)
        
        let secondPoster = app.images[Constants.Identifiers.movieImage]
        let secondPosterImageData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterImageData, secondPosterImageData)
    }
    
    func testNoButton() throws {
        sleep(Constants.delay)
        
        let firstPoster = app.images[Constants.Identifiers.movieImage]
        let firstPosterImageData = firstPoster.screenshot().pngRepresentation
        
        app.buttons[Constants.Identifiers.buttonNo].tap()
        
        sleep(Constants.delay)
        
        let secondPoster = app.images[Constants.Identifiers.movieImage]
        let secondPosterImageData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterImageData, secondPosterImageData)
    }
    
    func testEndOfRound() throws {
        sleep(Constants.delay)
        
        for _ in 1...Constants.countQuestions {
            let buttonIdentifier = [Constants.Identifiers.buttonYes, Constants.Identifiers.buttonNo].randomElement()!
            
            app.buttons[buttonIdentifier].tap()
            
            sleep(Constants.delay)
        }
        
        let alert = app.alerts[Constants.Identifiers.resultAlert]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == Constants.Texts.alertTitle)
        XCTAssertTrue(alert.buttons.firstMatch.label == Constants.Texts.alertButtonTitle)
    }
    
    func testRestartRound() throws {
        sleep(Constants.delay)
        
        for _ in 1...Constants.countQuestions {
            let buttonIdentifier = [Constants.Identifiers.buttonYes, Constants.Identifiers.buttonNo].randomElement()!
            
            app.buttons[buttonIdentifier].tap()
            
            sleep(Constants.delay)
        }
        
        let alert = app.alerts[Constants.Identifiers.resultAlert]
        
        XCTAssertTrue(alert.exists)
        
        alert.buttons.firstMatch.tap()
        
        sleep(Constants.delay)
        
        XCTAssertFalse(alert.exists)
        
        let questionCounterLabel = app.staticTexts[Constants.Identifiers.questionCounterLabel]
        
        XCTAssertEqual(questionCounterLabel.label, Constants.Texts.initQuestionCounterText)
    }
}

// MARK: - Constants
private extension MovieQuizUITests {
    enum Constants {
        static let delay: UInt32 = 3
        static let countQuestions = 10
        
        enum Identifiers {
            static let buttonYes = "buttonYes"
            static let buttonNo = "buttonNo"
            static let resultAlert = "resultAlert"
            static let movieImage = "poster"
            static let questionCounterLabel = "questionCounterLabel"
        }
        
        enum Texts {
            static let alertTitle = "Этот раунд окончен!"
            static let alertButtonTitle = "Сыграть ещё раз"
            static let initQuestionCounterText = "1/10"
        }
    }
}
