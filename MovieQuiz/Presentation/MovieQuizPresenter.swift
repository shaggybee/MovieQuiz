//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 12.01.2026.
//

import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Private Properties
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let questionsAmount = 10
    private var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private lazy var statisticService: StatisticServiceProtocol = { StatisticService() }()
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
        self.viewController?.changeButtonsState(isEnabled: false)
    }
    
    // MARK: - Public Methods
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion {
            saveGameResult()
            viewController?.show(quiz: prepareQuizResults())
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.changeButtonsState(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.viewController?.changeButtonsState(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    private func saveGameResult() {
        let gameResult = GameResult(
            correct: correctAnswers,
            total: questionsAmount,
            date: Date())
        
        statisticService.store(result: gameResult)
    }
    
    private func prepareQuizResults() -> QuizResultsViewModel {
        let totalAccuracyFormatted = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        
        let resultText = "\(Constants.Text.result): \(correctAnswers)/\(questionsAmount)"
        let gamesCountText = "\(Constants.Text.gamesCount): \(statisticService.gamesCount)"
        let recordText = "\(Constants.Text.record): \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let totalAccuracyText = "\(Constants.Text.averageAccuracy): \(totalAccuracyFormatted)%"
        
        let text = """
            \(resultText)
            \(gamesCountText)
            \(recordText)
            \(totalAccuracyText)
            """
        
        return QuizResultsViewModel(
            title: "\(Constants.Text.roundOver)",
            text: text,
            buttonText: "\(Constants.Text.playAgain)")
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        
        let model = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: model)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
        viewController?.changeButtonsState(isEnabled: true)
    }

    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}

// MARK: - Constants
private extension MovieQuizPresenter {
    enum Constants {
        enum Text {
            static let result = "Ваш результат"
            static let gamesCount = "Количество сыгранных квизов"
            static let record = "Рекорд"
            static let averageAccuracy = "Средняя точность"
            static let roundOver = "Этот раунд окончен!"
            static let playAgain = "Сыграть ещё раз"
        }
    }
}
