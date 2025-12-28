//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 25.12.2025.
//

import Foundation

struct MoviesLoader {
    
    // MARK: - Private Properties
    private let networkClient = NetworkClient()
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: Constants.moviesUrlString) else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
}

// MARK: - MoviesLoadingProtocol
extension MoviesLoader: MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

// MARK: - Constants
private extension MoviesLoader {
    enum Constants {
        static let moviesUrlString = "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
    }
}
