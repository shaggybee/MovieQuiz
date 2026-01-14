//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Kislov Vadim on 14.01.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)

        let question = QuizQuestion(
            image: Data(),
            text: Constants.Texts.questionText,
            correctAnswer: true)
        
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, Constants.Texts.questionText)
        XCTAssertEqual(viewModel.questionNumber, Constants.Texts.initQuestionCounterText)
    }
}

// MARK: - Constants
private extension MovieQuizPresenterTests {
    enum Constants {
        enum Texts {
            static let questionText = "some question"
            static let initQuestionCounterText = "1/10"
        }
    }
}
