//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 13.12.2025.
//

import Foundation

final class StatisticService {
    
    // MARK: - Nested Types
    private enum StatisticKey: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
}

// MARK: - StatisticServiceProtocol
extension StatisticService: StatisticServiceProtocol {
    
    // MARK: - Public Properties
    var gamesCount: Int {
        get {
            storage.integer(forKey: StatisticKey.gamesCount.rawValue)
        }
        
        set {
            storage.setValue(newValue, forKey: StatisticKey.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: StatisticKey.bestGameCorrect.rawValue),
                total: storage.integer(forKey: StatisticKey.bestGameTotal.rawValue),
                date: storage.object(forKey: StatisticKey.bestGameDate.rawValue) as? Date ?? Date())
        }
        
        set {
            storage.setValue(newValue.total, forKey: StatisticKey.bestGameTotal.rawValue)
            storage.setValue(newValue.correct, forKey: StatisticKey.bestGameCorrect.rawValue)
            storage.setValue(newValue.date, forKey: StatisticKey.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            if totalCorrectAnswers == 0 || totalQuestionsAsked == 0 {
                return 0
            }
                
            return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100.0
        }
    }
    
    // MARK: - Private Properties
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: StatisticKey.totalCorrectAnswers.rawValue)
        }
        
        set {
            storage.setValue(newValue, forKey: StatisticKey.totalCorrectAnswers.rawValue)
        }
    }
    
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: StatisticKey.totalQuestionsAsked.rawValue)
        }
        
        set {
            storage.setValue(newValue, forKey: StatisticKey.totalQuestionsAsked.rawValue)
        }
    }
    
    // MARK: - Public methods
    func store(result: GameResult) {
        gamesCount += 1
        totalCorrectAnswers += result.correct
        totalQuestionsAsked += result.total
        
        if result.isBetterThan(bestGame) {
            bestGame = result
        }
    }
}

