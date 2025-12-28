//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 09.12.2025.
//

import UIKit

final class QuestionFactory {
    
    // MARK: - Public Properties
    weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Private Properties
    private let moviesLoader: MoviesLoadingProtocol
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}

// MARK: - QuestionFactoryProtocol
extension QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Public methods
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }
            
            let question = getQuizQuestion(for: movie)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func getQuizQuestion(for movie: MostPopularMovie) -> QuizQuestion {
        var imageData = Data()
       
        do {
            imageData = try Data(contentsOf: movie.resizedImageURL)
        } catch {
            imageData = getFallbackImageData(for: movie)
        }
        
        let movieRating = Float(movie.rating) ?? 0

        var correctAnswer = false
        
        var ratingWithDelta = Bool.random()
            ? movieRating - Constants.ratingDelta
            : movieRating + Constants.ratingDelta
        
        if ratingWithDelta == Constants.maxRating {
            ratingWithDelta -= 2 * Constants.ratingDelta
        }
        
        var questionText = "\(String(format: "%.1f", ratingWithDelta))?"

        if Bool.random() {
            correctAnswer = movieRating > ratingWithDelta
            questionText = "\(Constants.Text.isRatingHigher) \(questionText)"
        } else {
            correctAnswer = movieRating < ratingWithDelta
            questionText = "\(Constants.Text.isRatingLower) \(questionText)"
        }
        
        return QuizQuestion(
            image: imageData,
            text: questionText,
            correctAnswer: correctAnswer)
    }
    
    private func getFallbackImageData(for movie: MostPopularMovie) -> Data {
        let title = "\(movie.title)" as NSString
        let imageSize = CGSize(width: 200, height: 300)
        let imageRenderer = UIGraphicsImageRenderer(size: imageSize)
        
        return imageRenderer.pngData { _ in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "YSDisplay-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.ypBlack,
                .paragraphStyle: paragraphStyle
            ]
            
            let textSize = title.size(withAttributes: attributes)

            let textRect = CGRect(
                x: 0,
                y: (imageSize.height - textSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )

            title.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// MARK: - Constants
private extension QuestionFactory {
    enum Constants {
        static let maxRating: Float = 10.0
        static let higherRating: Float = 9.0
        static let ratingDelta: Float = 0.3
        
        enum Text {
            static let isRatingHigher = "Рейтинг этого фильма больше чем"
            static let isRatingLower = "Рейтинг этого фильма меньше чем"
        }
    }
}
