import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private lazy var resultAlertPresenter: ResultAlertPresenter = { ResultAlertPresenter() }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        configUI()
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            accessibilityIdentifier: "resultAlert",
            completion: { [weak self] in
                guard let self else { return }
                
                self.presenter.restartGame()
            })
        
        resultAlertPresenter.show(in: self, model: alertModel)
    }
    
    func showNetworkError(message: String) {
        let alertModel = AlertModel(
            title: "\(Constants.Text.somethingWrong)",
            message: message,
            buttonText: "\(Constants.Text.tryAgain)",
            completion: { [weak self] in
                guard let self else { return }
                
                self.presenter.restartGame()
            })
        
        resultAlertPresenter.show(in: self, model: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
    }
    
    func changeButtonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Private Methods
    private func configUI() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .ypRed
        
        imageView.layer.borderWidth = Constants.imageBorderWidth
    }
}

// MARK: - Constants
private extension MovieQuizViewController {
    enum Constants {
        static let imageBorderWidth: CGFloat = 8
        
        enum Text {
            static let somethingWrong = "Что-то пошло не так("
            static let tryAgain = "Попробовать еще раз"
        }
    }
}
