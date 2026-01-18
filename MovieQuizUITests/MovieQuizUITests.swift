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
        let firstPoster = app.images[Constants.Identifiers.movieImage]
        
        expectationExistenceState(for: firstPoster)
        
        let firstPosterImageData = firstPoster.screenshot().pngRepresentation
        
        app.buttons[Constants.Identifiers.buttonYes].tap()
        
        let secondPoster = app.images[Constants.Identifiers.movieImage]
        
        expectationExistenceState(for: secondPoster)
        
        let secondPosterImageData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterImageData, secondPosterImageData)
    }
    
    func testNoButton() throws {
        let firstPoster = app.images[Constants.Identifiers.movieImage]
        
        expectationExistenceState(for: firstPoster)
        
        let firstPosterImageData = firstPoster.screenshot().pngRepresentation
        
        app.buttons[Constants.Identifiers.buttonNo].tap()
        
        let secondPoster = app.images[Constants.Identifiers.movieImage]
        
        expectationExistenceState(for: secondPoster)
        
        let secondPosterImageData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterImageData, secondPosterImageData)
    }
    
    func testEndOfRound() throws {
        for questionindex in 1...Constants.countQuestions {
            let questionCounterLabel = app.staticTexts["\(questionindex)/\(Constants.countQuestions)"]
            
            expectationExistenceState(for: questionCounterLabel)
            
            let buttonIdentifier = [Constants.Identifiers.buttonYes, Constants.Identifiers.buttonNo].randomElement()!
            let button = app.buttons[buttonIdentifier]
            
            expectationExistenceState(for: button)
            
            button.tap()
        }
        
        let alert = app.alerts[Constants.Identifiers.resultAlert]
        
        expectationExistenceState(for: alert)

        XCTAssertTrue(alert.label == Constants.Texts.alertTitle)
        XCTAssertTrue(alert.buttons.firstMatch.label == Constants.Texts.alertButtonTitle)
    }
    
    func testRestartRound() throws {
        for questionindex in 1...Constants.countQuestions {
            let questionCounterLabel = app.staticTexts["\(questionindex)/\(Constants.countQuestions)"]
            
            expectationExistenceState(for: questionCounterLabel)
            
            let buttonIdentifier = [Constants.Identifiers.buttonYes, Constants.Identifiers.buttonNo].randomElement()!
            let button = app.buttons[buttonIdentifier]
            
            expectationExistenceState(for: button)
            
            button.tap()
        }
        
        let alert = app.alerts[Constants.Identifiers.resultAlert]
        
        expectationExistenceState(for: alert)
        
        alert.buttons.firstMatch.tap()
        
        expectationExistenceState(for: alert, isExists: false)
        
        let questionCounterLabel = app.staticTexts[Constants.Texts.initQuestionCounterText]
        
        expectationExistenceState(for: questionCounterLabel)
    }

    private func expectationExistenceState(
        for element: XCUIElement,
        isExists: Bool = true
    ) {
        let predicate = NSPredicate(format: "exists == \(isExists)")
        
        expectation(
            for: predicate,
            evaluatedWith: element)
        
        waitForExpectations(timeout: Constants.delay)
    }
}

// MARK: - Constants
private extension MovieQuizUITests {
    enum Constants {
        static let delay: Double = 3
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
