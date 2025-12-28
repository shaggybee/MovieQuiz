//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 09.12.2025.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
