import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    private lazy var resultAlertPresenter: ResultAlertPresenter = { ResultAlertPresenter() }()
    private lazy var statisticService: StatisticServiceProtocol = { StatisticService() }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        changeButtonsState(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = .none
            
            self.changeButtonsState(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          let gameResult = GameResult(
            correct: correctAnswers,
            total: questionsAmount,
            date: Date())
          
          statisticService.store(result: gameResult)
    
          show(quiz: prepareQuizResults())
      } else {
        currentQuestionIndex += 1
          
        questionFactory?.requestNextQuestion()
      }
    }
    
    private func prepareQuizResults() -> QuizResultsViewModel {
        let totalAccuracyFormatted = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        
        let resultText = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let recordText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let totalAccuracyText = "Средняя точность: \(totalAccuracyFormatted)%"
        
        let text = """
            \(resultText)
            \(gamesCountText)
            \(recordText)
            \(totalAccuracyText)
            """
        
        return QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                
                self.questionFactory?.requestNextQuestion()
            })
        
        resultAlertPresenter.show(in: self, model: alertModel)
    }
    
    private func changeButtonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        
        let model = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: model)
        }
    }
}
