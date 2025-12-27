//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 09.12.2025.
//

import Foundation

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
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let movieRating = Float(movie.rating) ?? 0
            let randomRatingForQuestion = Int.random(in: 7..<10)
            
            let text = "Рейтинг этого фильма больше чем \(randomRatingForQuestion)?"
            let correctAnswer = movieRating > Float(randomRatingForQuestion)
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

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
}
