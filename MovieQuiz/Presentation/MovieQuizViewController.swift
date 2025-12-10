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
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
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
            guard let self = self else { return }
            
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = .none
            
            self.changeButtonsState(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          let resultsViewModel = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
              buttonText: "Сыграть ещё раз")
          
          show(quiz: resultsViewModel)
      } else {
        currentQuestionIndex += 1
          
        questionFactory?.requestNextQuestion()
      }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let actionRepeat = UIAlertAction(
            title: result.buttonText,
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alert.addAction(actionRepeat)
        
       present(alert, animated: true, completion: nil)
    }
    
    private func changeButtonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        
        let model = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: model)
        }
    }
}
