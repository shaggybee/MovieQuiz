//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 10.12.2025.
//

import UIKit

final class ResultAlertPresenter {
    
    // MARK: - Public methods
    func show(in viewControllerToPresent: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default,
            handler: { _ in
                model.completion()
            }
        )
        
        alert.addAction(action)
        
        viewControllerToPresent.present(
            alert, 
            animated: true, 
            completion: nil)
    }
}
