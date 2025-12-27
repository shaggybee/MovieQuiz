//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 25.12.2025.
//

import Foundation

protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
