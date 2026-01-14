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
        
        let questionText = "some question"
        let question = QuizQuestion(
            image: Data(),
            text: questionText,
            correctAnswer: true)
        
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, questionText)
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
