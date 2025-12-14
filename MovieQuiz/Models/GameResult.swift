//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 13.12.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ anotherResult: GameResult) -> Bool {
        correct > anotherResult.correct
    }
}
