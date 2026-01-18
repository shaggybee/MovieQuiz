//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 05.01.2026.
//

import Foundation

protocol NetworkRoutingProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
