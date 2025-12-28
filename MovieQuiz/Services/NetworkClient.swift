//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 25.12.2025.
//

import Foundation

struct NetworkClient {

    // MARK: - Nested Types
    private enum NetworkError: Error {
        case codeError
    }
    
    // MARK: - Public methods
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                handler(.failure(error))
                
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < Constants.successfulStatusCategory || response.statusCode >= Constants.redirectionStatusCategory {
                handler(.failure(NetworkError.codeError))
                return
            }

            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}

// MARK: - Constants
private extension NetworkClient {
    enum Constants {
        static let successfulStatusCategory = 200
        static let redirectionStatusCategory = 300
    }
}

