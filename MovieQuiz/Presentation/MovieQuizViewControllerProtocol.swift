//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 14.01.2026.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func changeButtonsState(isEnabled: Bool)
    
    func showNetworkError(message: String)
}
